`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2026 08:06:19 PM
// Design Name: 
// Module Name: tb_microblaze_complete
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module tb_microblaze_complete(

    );
    // ============================================================
    // Frame parameters
    // ============================================================

    localparam integer FRAME_WIDTH  = 320;
    localparam integer FRAME_HEIGHT = 200;

    // 1 bit per pixel
    localparam integer FRAME_BYTES = FRAME_WIDTH * FRAME_HEIGHT;

    // ============================================================
    // DUT signals
    // ============================================================

    logic       data_clk_0;
    logic       reset_rtl;

    logic [7:0] s_axis_0_tdata;
    logic       s_axis_0_tready;
    logic       s_axis_0_tvalid;

    logic [0:0] start_btn_tri_i;

    logic       sys_clock;


    // ============================================================
    // Counters
    // ============================================================

    integer input_count;

    // ============================================================
    // DUT
    // ============================================================

    design_1_wrapper dut (
        .data_clk_0       (data_clk_0),
        .reset_rtl        (reset_rtl),

        .s_axis_0_tdata   (s_axis_0_tdata),
        .s_axis_0_tready  (s_axis_0_tready),
        .s_axis_0_tvalid  (s_axis_0_tvalid),

        .start_btn_tri_i  (start_btn_tri_i),

        .sys_clock        (sys_clock)
    );

    // ============================================================
    // 100 MHz system clock
    // Period = 10 ns
    // ============================================================

    initial begin
        sys_clock = 1'b0;

        forever
            #5 sys_clock = ~sys_clock;
    end


    // ============================================================
    // 25 MHz input data clock
    // Period = 40 ns
    // ============================================================

    initial begin
        data_clk_0 = 1'b0;

        forever
            #20 data_clk_0 = ~data_clk_0;
    end


    // ============================================================
    // Send one byte using AXI-Stream handshake
    // ============================================================

    task automatic send_byte(
        input logic [7:0] data
    );
    begin
        s_axis_0_tdata  <= data;
        s_axis_0_tvalid <= 1'b1;

        // Wait until DUT accepts the byte.
        //
        // Transfer occurs when:
        //
        // tvalid = 1
        // tready = 1
        //
        while (!s_axis_0_tready)
            @(posedge data_clk_0);

        @(posedge data_clk_0);

        s_axis_0_tvalid <= 1'b0;

        input_count = input_count + 1;

    end
    endtask


    // ============================================================
    // Send one complete frame
    // ============================================================

    task automatic send_frame;
        integer i;
    begin

        $display("");
        $display("==========================================");
        $display("Sending frame");
        $display("Frame bytes = %0d", FRAME_BYTES);
        $display("==========================================");

        for (i = 0; i < FRAME_BYTES; i = i + 1) begin

            send_byte(i[7:0]);

            if ((input_count % 500) == 0) begin
                $display(
                    "Sent %0d / %0d bytes",
                    input_count,
                    FRAME_BYTES
                );
            end

        end

        $display("");
        $display("Frame input complete");
        $display("Input bytes = %0d", input_count);
        $display("");

    end
    endtask


    // ============================================================
    // Main simulation
    // ============================================================

    initial begin

        // Initial values
        reset_rtl       = 1'b0;

        s_axis_0_tdata  = 8'h00;
        s_axis_0_tvalid = 1'b0;

        start_btn_tri_i = 1'b0;

        input_count = 0;


        // --------------------------------------------------------
        // Reset
        // --------------------------------------------------------

        $display("Applying reset...");

        #200;

        reset_rtl = 1'b1;

        $display("Reset released");


        // --------------------------------------------------------
        // Give MicroBlaze/system some time to initialize
        // --------------------------------------------------------

        #100_000;

        $display("");
        $display("System initialization period complete");


        // --------------------------------------------------------
        // Press button
        // --------------------------------------------------------

        $display("");
        $display("Pressing START button");

        start_btn_tri_i[0] = 1'b1;

        // Hold button long enough for MicroBlaze polling
        #10_000;

        start_btn_tri_i[0] = 1'b0;

        $display("START button released");


        // --------------------------------------------------------
        // Give MicroBlaze time to detect button and start DMA
        // --------------------------------------------------------

        #50_000;


        // --------------------------------------------------------
        // Send one complete frame
        // --------------------------------------------------------

        send_frame;


        // --------------------------------------------------------
        // Give DMA enough time to finish
        // --------------------------------------------------------

        $display("");
        $display("Waiting for DMA to complete...");

        #200_000;


        // --------------------------------------------------------
        // Done
        // --------------------------------------------------------

        $display("");
        $display("==========================================");
        $display("SIMULATION FINISHED");
        $display("Input bytes = %0d", input_count);
        $display("==========================================");
        $display("");

        $finish;

    end


    // ============================================================
    // Timeout
    // ============================================================

    initial begin

        #20_000_000;

        $display("");
        $display("ERROR: Simulation timeout");
        $display(
            "Only %0d / %0d bytes were sent",
            input_count,
            FRAME_BYTES
        );

        $finish;

    end

endmodule