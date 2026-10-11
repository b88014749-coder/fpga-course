`timescale 1 ns / 1 ps

module tb_freq_cntr;

    // =====================================================
    // Clock, reset, and external input signal
    // =====================================================

    reg clk;
    reg resetn;
    reg sig_in;

    // AXI4-Lite write address channel
    reg  [3:0] awaddr;
    reg  [2:0] awprot;
    reg        awvalid;
    wire       awready;

    // AXI4-Lite write data channel
    reg  [31:0] wdata;
    reg  [3:0]  wstrb;
    reg         wvalid;
    wire        wready;

    // AXI4-Lite write response channel
    wire [1:0] bresp;
    wire       bvalid;
    reg        bready;

    // AXI4-Lite read address channel
    reg  [3:0] araddr;
    reg  [2:0] arprot;
    reg        arvalid;
    wire       arready;

    // AXI4-Lite read data channel
    wire [31:0] rdata;
    wire [1:0]  rresp;
    wire        rvalid;
    reg         rready;

    // =====================================================
    // Register addresses
    // =====================================================

    localparam [3:0] ADDR_WINDOW = 4'h0;
    localparam [3:0] ADDR_CTRL   = 4'h4;
    localparam [3:0] ADDR_COUNT  = 4'h8;
    localparam [3:0] ADDR_STATUS = 4'hC;

    // =====================================================
    // Device under test
    // =====================================================

    freq_cntr #(
        .C_S_AXI_DATA_WIDTH(32),
        .C_S_AXI_ADDR_WIDTH(4)
    ) dut (
        .S_AXI_ACLK    (clk),
        .S_AXI_ARESETN (resetn),

        .S_AXI_AWADDR  (awaddr),
        .S_AXI_AWPROT  (awprot),
        .S_AXI_AWVALID (awvalid),
        .S_AXI_AWREADY (awready),

        .S_AXI_WDATA   (wdata),
        .S_AXI_WSTRB   (wstrb),
        .S_AXI_WVALID  (wvalid),
        .S_AXI_WREADY  (wready),

        .S_AXI_BRESP   (bresp),
        .S_AXI_BVALID  (bvalid),
        .S_AXI_BREADY  (bready),

        .S_AXI_ARADDR  (araddr),
        .S_AXI_ARPROT  (arprot),
        .S_AXI_ARVALID (arvalid),
        .S_AXI_ARREADY (arready),

        .S_AXI_RDATA   (rdata),
        .S_AXI_RRESP   (rresp),
        .S_AXI_RVALID  (rvalid),
        .S_AXI_RREADY  (rready),

        .sig_in        (sig_in)
    );

    // =====================================================
    // Clock generation
    // Clock period = 10 ns (100 MHz)
    // =====================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // =====================================================
    // Input signal generation
    // =====================================================

    integer half_period;

    initial begin
        sig_in = 1'b0;
        half_period = 50;

        forever begin
            #(half_period * 10);
            sig_in = ~sig_in;
        end
    end

    // =====================================================
    // AXI4-Lite WRITE TASK
    // =====================================================

    task axi_write;
        input [3:0]  addr;
        input [31:0] data;

        reg aw_done;
        reg w_done;
        reg b_done;

        begin
            @(negedge clk);

            awaddr  = addr;
            awvalid = 1'b1;

            wdata   = data;
            wstrb   = 4'b1111;
            wvalid  = 1'b1;

            aw_done = 1'b0;
            w_done  = 1'b0;
            b_done  = 1'b0;

            // Wait for address and data handshakes.
            while (!aw_done || !w_done) begin
                @(posedge clk);

                if (awvalid && awready)
                    aw_done = 1'b1;

                if (wvalid && wready)
                    w_done = 1'b1;

                @(negedge clk);

                if (aw_done)
                    awvalid = 1'b0;

                if (w_done)
                    wvalid = 1'b0;
            end

            // Wait for the write response.
            bready = 1'b1;

            while (bvalid !== 1'b1) begin
                @(negedge clk);
            end

            // Accept the response on the next rising edge.
            @(posedge clk);

            if (bvalid && bready)
                b_done = 1'b1;

            @(negedge clk);

            bready = 1'b0;

            if (!b_done) begin
                $display("[%0t ns] ERROR: Write response failed.",
                         $time);
                $fatal(1);
            end
        end
    endtask

    // =====================================================
    // AXI4-Lite READ TASK
    // =====================================================

    task axi_read;
        input  [3:0]  addr;
        output [31:0] data;

        reg ar_done;
        reg r_done;
        integer timeout;

        begin
            ar_done = 1'b0;
            r_done  = 1'b0;
            timeout = 0;
            data    = 32'h00000000;

            @(negedge clk);

            araddr  = addr;
            arvalid = 1'b1;
            rready  = 1'b1;

            // Wait for the address handshake.
            while (!ar_done && timeout < 100) begin
                @(posedge clk);

                if (arvalid && arready)
                    ar_done = 1'b1;

                @(negedge clk);

                if (ar_done)
                    arvalid = 1'b0;

                timeout = timeout + 1;
            end

            if (!ar_done) begin
                $display("[%0t ns] ERROR: AXI read address timeout.",
                         $time);
                $fatal(1);
            end

            timeout = 0;

            // Wait for the read-data handshake.
            while (!r_done && timeout < 100) begin
                @(posedge clk);

                if (rvalid && rready) begin
                    data   = rdata;
                    r_done = 1'b1;
                end

                @(negedge clk);
                timeout = timeout + 1;
            end

            rready = 1'b0;

            if (!r_done) begin
                $display("[%0t ns] ERROR: AXI read data timeout.",
                         $time);
                $fatal(1);
            end
        end
    endtask

    // =====================================================
    // WAIT FOR MEASUREMENT COMPLETION
    // =====================================================

    task wait_for_done;

        reg [31:0] status_value;
        integer timeout;

        begin
            status_value = 32'h00000000;
            timeout = 0;

            while ((status_value[0] !== 1'b1) &&
                   (timeout < 10000)) begin

                axi_read(ADDR_STATUS, status_value);

                timeout = timeout + 1;
            end

            if (status_value[0] !== 1'b1) begin
                $display("[%0t ns] ERROR: Measurement timed out.",
                         $time);
                $fatal(1);
            end

            $display("[%0t ns] Measurement completed.", $time);
        end
    endtask

    // =====================================================
    // RUN ONE MEASUREMENT TEST
    // =====================================================

    task run_test;
        input integer period_cycles;
        input integer window_cycles;
        input integer expected_min;
        input integer expected_max;

        reg [31:0] count_value;
        reg [31:0] status_value;

        begin
            $display("");
            $display("========================================");
            $display("Starting measurement test");
            $display("Input period : %0d clock cycles",
                     period_cycles);
            $display("Window       : %0d clock cycles",
                     window_cycles);
            $display("Expected     : COUNT = %0d..%0d",
                     expected_min, expected_max);
            $display("========================================");

            if ((period_cycles % 2) != 0) begin
                $display("ERROR: Period must be even.");
                $fatal(1);
            end

            half_period = period_cycles / 2;

            // Allow the input signal to settle.
            repeat (5) @(posedge clk);

            // Configure measurement window.
            axi_write(ADDR_WINDOW, window_cycles);

            // Start measurement by writing 1 to CTRL[0].
            axi_write(ADDR_CTRL, 32'h00000001);

            // Wait for completion.
            wait_for_done();

            // Read result and status.
            axi_read(ADDR_COUNT, count_value);
            axi_read(ADDR_STATUS, status_value);

            // Verify STATUS.
            if (status_value[0] !== 1'b1) begin
                $display("FAIL: STATUS[0] should be 1.");
                $fatal(1);
            end

            // Verify COUNT.
            if ((count_value < expected_min) ||
                (count_value > expected_max)) begin

                $display("FAIL: COUNT = %0d", count_value);
                $display("Expected range: %0d..%0d",
                         expected_min, expected_max);

                $fatal(1);
            end
            else begin
                $display("PASS: COUNT = %0d", count_value);
            end

            repeat (5) @(posedge clk);
        end
    endtask

    // =====================================================
    // MAIN TEST SEQUENCE
    // =====================================================

    initial begin

        // Reset.
        resetn = 1'b0;

        // Initialize write channel.
        awaddr  = 4'h0;
        awprot  = 3'b000;
        awvalid = 1'b0;

        wdata   = 32'h00000000;
        wstrb   = 4'b0000;
        wvalid  = 1'b0;

        bready  = 1'b0;

        // Initialize read channel.
        araddr  = 4'h0;
        arprot  = 3'b000;
        arvalid = 1'b0;

        rready  = 1'b0;

        half_period = 50;

        // Hold reset for 10 clock cycles.
        repeat (10) @(posedge clk);

        @(negedge clk);
        resetn = 1'b1;

        repeat (5) @(posedge clk);

        // TEST 1:
        // Period = 100 cycles, window = 1000 cycles.
        run_test(100, 1000, 10, 10);

        // TEST 2:
        // Period = 40 cycles, window = 2000 cycles.
        run_test(40, 2000, 50, 50);

        // TEST 3:
        // Period = 100 cycles, window = 250 cycles.
        run_test(100, 250, 2, 3);

        $display("");
        $display("========================================");
        $display("ALL TESTS COMPLETED");
        $display("========================================");

        $finish;
    end

    // =====================================================
    // GLOBAL SIMULATION TIMEOUT
    // =====================================================

    initial begin
        #100000000;
        $display("ERROR: Global simulation timeout.");
        $fatal(1);
    end

endmodule