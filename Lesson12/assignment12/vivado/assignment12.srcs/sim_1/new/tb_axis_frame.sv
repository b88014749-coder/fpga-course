`timescale 1ns/1ps

module tb_axis_frame;

    localparam DATA_WIDTH_IN  = 8;
    localparam DATA_WIDTH_OUT = 32;
    localparam FIFO_DEPTH     = 32;

    localparam FRAME_WIDTH    = 320;
    localparam FRAME_HEIGHT   = 200;

    localparam FRAME_BYTES = (FRAME_WIDTH * FRAME_HEIGHT);

    localparam FRAME_WORDS = FRAME_BYTES / (DATA_WIDTH_OUT / DATA_WIDTH_IN);

    logic aclk;
    logic data_clk;
    logic aresetn;

    logic start;

    logic [DATA_WIDTH_IN-1:0] s_axis_tdata;
    logic                     s_axis_tvalid;
    logic                     s_axis_tready;

    logic [DATA_WIDTH_OUT-1:0] m_axis_tdata;
    logic                      m_axis_tvalid;
    logic                      m_axis_tready;
    logic                      m_axis_tlast;

    integer input_count;
    integer output_count;
    integer error_count;


    // 100 MHz AXI clock
    initial begin
        aclk = 1'b0;

        forever #5 aclk = ~aclk;
    end


    // 25 MHz input data clock
    initial begin
        data_clk = 1'b0;

        forever #20 data_clk = ~data_clk;
    end


    // DUT
    axis_frame #(
        .DATA_WIDTH_IN  (DATA_WIDTH_IN),
        .DATA_WIDTH_OUT (DATA_WIDTH_OUT),
        .FIFO_DEPTH     (FIFO_DEPTH),
        .FRAME_WIDTH    (FRAME_WIDTH),
        .FRAME_HEIGHT   (FRAME_HEIGHT)
    ) dut (
        .aclk           (aclk),
        .aresetn        (aresetn),

        .data_clk       (data_clk),

        .start          (start),

        .s_axis_tdata   (s_axis_tdata),
        .s_axis_tvalid  (s_axis_tvalid),
        .s_axis_tready  (s_axis_tready),

        .m_axis_tdata   (m_axis_tdata),
        .m_axis_tvalid  (m_axis_tvalid),
        .m_axis_tready  (m_axis_tready),
        .m_axis_tlast   (m_axis_tlast)
    );


    // Reset and start
    initial begin
        aresetn       = 1'b0;
        start         = 1'b0;

        s_axis_tdata  = 8'h00;
        s_axis_tvalid = 1'b0;

        m_axis_tready = 1'b0;

        input_count   = 0;
        output_count  = 0;
        error_count   = 0;

        // Reset
        #100;

        aresetn = 1'b1;

        // Allow the design to leave reset
        #100;

        // Start frame acquisition
        start = 1'b1;

        // Keep start asserted long enough for the frame
        #(FRAME_BYTES * 40 + 1000);

        start = 1'b0;
    end


    // Send one input byte
    task automatic send_byte(
        input logic [7:0] data
    );
        begin
            // Wait until DUT can accept data
            while (!s_axis_tready)
                @(posedge data_clk);

            s_axis_tdata  <= data;
            s_axis_tvalid <= 1'b1;

            @(posedge data_clk);

            // Wait until the transfer is accepted
            while (!s_axis_tready)
                @(posedge data_clk);

            s_axis_tvalid <= 1'b0;

            input_count = input_count + 1;
        end
    endtask


    // Generate the complete frame
    initial begin
        wait(aresetn);
        wait(start);

        // Wait until start has propagated to data_clk domain
        wait(s_axis_tready);

        for (integer i = 0; i < FRAME_BYTES; i++) begin
            send_byte(i[7:0]);
        end

        $display("");
        $display("Input complete: %0d bytes sent", input_count);
        $display("");
    end


    // Simulated DMA
    //
    // Introduce backpressure randomly.
    //
    // This checks that axis_frame keeps
    // m_axis_tdata and m_axis_tlast stable
    // while m_axis_tready is low.

    initial begin
        wait(aresetn);
        #500;

        forever begin
            // DMA ready
            m_axis_tready = 1'b1;
            repeat ($urandom_range(5, 20))
                @(posedge aclk);
            // DMA temporarily not ready
            m_axis_tready = 1'b0;
            repeat ($urandom_range(2, 8))
                @(posedge aclk);
        end
    end

    // AXI output checker
    always @(posedge aclk) begin
        if (m_axis_tvalid && m_axis_tready) begin
            logic [31:0] expected_data;

            logic [7:0] expected_b0;
            logic [7:0] expected_b1;
            logic [7:0] expected_b2;
            logic [7:0] expected_b3;

            integer base_byte;

            // First byte belonging to this output word
            base_byte = output_count * 4;

            // Expected four input bytes
            expected_b0 = (base_byte + 0) & 8'hFF;
            expected_b1 = (base_byte + 1) & 8'hFF;
            expected_b2 = (base_byte + 2) & 8'hFF;
            expected_b3 = (base_byte + 3) & 8'hFF;

            // Little-endian packing
            //
            // byte 0 -> bits [7:0]
            // byte 1 -> bits [15:8]
            // byte 2 -> bits [23:16]
            // byte 3 -> bits [31:24]

            expected_data = {
                expected_b3,
                expected_b2,
                expected_b1,
                expected_b0
            };

            // Check data
            if (m_axis_tdata !== expected_data) begin
                $error(
                    "Word %0d incorrect: expected %08h, got %08h",
                    output_count,
                    expected_data,
                    m_axis_tdata
                );
                error_count = error_count + 1;
            end


            // Check TLAST
            if (output_count == FRAME_WORDS - 1) begin
                if (m_axis_tlast !== 1'b1) begin
                    $error(
                        "Final word missing TLAST"
                    );
                    error_count = error_count + 1;
                end
            end
            else begin
                if (m_axis_tlast !== 1'b0) begin
                    $error(
                        "Unexpected TLAST on word %0d",
                        output_count
                    );
                    error_count = error_count + 1;
                end
            end

            // Count accepted AXI words
            output_count = output_count + 1;

            // Progress information
            if ((output_count % 100) == 0) begin
                $display(
                    "Received %0d / %0d AXI words",
                    output_count,
                    FRAME_WORDS
                );
            end

            // Complete frame
            if (output_count == FRAME_WORDS) begin
                $display("");
                $display("====================================");
                if (error_count == 0) begin
                    $display("FULL FRAME TEST PASSED");
                end
                else begin
                    $display("FULL FRAME TEST FAILED");
                end

                $display("Input bytes : %0d", input_count);
                $display("Output words: %0d", output_count);
                $display("Errors      : %0d", error_count);
                $display("====================================");
                $display("");

                #100;

                $finish;
            end
        end
    end
endmodule
