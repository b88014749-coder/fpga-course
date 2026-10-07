`timescale 1ns/1ps
// tb_moving_max.v

module tb_moving_max;

    localparam N_SAMPLES = 64;
    localparam WINDOW    = 8;

    // ------------------------------------------------------------
    // Clock and HLS control
    // ------------------------------------------------------------

    reg clk = 1'b0;
    reg rst = 1'b1;

    reg  ap_start = 1'b0;
    wire ap_done;
    wire ap_idle;
    wire ap_ready;

    // ------------------------------------------------------------
    // HLS memory interfaces
    // ------------------------------------------------------------

    wire [5:0]  in_data_address0;
    wire        in_data_ce0;
    wire [31:0] in_data_q0;

    wire [5:0]  out_data_address0;
    wire        out_data_ce0;
    wire        out_data_we0;
    wire [31:0] out_data_d0;

    // 100 MHz clock
    always #5 clk = ~clk;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------

    moving_max_0 dut (
        .ap_clk            (clk),
        .ap_rst            (rst),

        .ap_start          (ap_start),
        .ap_done           (ap_done),
        .ap_idle           (ap_idle),
        .ap_ready          (ap_ready),

        .in_data_address0  (in_data_address0),
        .in_data_ce0       (in_data_ce0),
        .in_data_q0        (in_data_q0),

        .out_data_address0 (out_data_address0),
        .out_data_ce0      (out_data_ce0),
        .out_data_we0      (out_data_we0),
        .out_data_d0       (out_data_d0)
    );

    reg signed [31:0] mem_in  [0:N_SAMPLES-1];
    reg signed [31:0] mem_out [0:N_SAMPLES-1];

    reg signed[31:0] q_a;

    /*
     * Simple synchronous-read RAM model.
     *
     * On a clock edge, if the DUT requests an input address,
     * the corresponding value is placed in q_a.
     *
     * The DUT receives q_a through in_data_q0.
     *
     * Output writes are performed when both CE and WE are asserted.
     */

    always @(posedge clk) begin

        if (in_data_ce0)
            q_a <= mem_in[in_data_address0];

        if (out_data_ce0 && out_data_we0)
            mem_out[out_data_address0] <= out_data_d0;

    end

    assign in_data_q0 = q_a;

    // ------------------------------------------------------------
    // Reference implementation
    // ------------------------------------------------------------

    reg [31:0] golden [0:N_SAMPLES-1];

    task make_golden;
        integer n;
        integer k;
        integer start;
        integer max_value;
        begin
            for (n = 0; n < N_SAMPLES; n = n + 1) begin
                start = n - WINDOW + 1;

                if (start < 0)
                    start = 0;

                max_value = mem_in[start];

                for (k = start + 1; k <= n; k = k + 1) begin
                    if (mem_in[k] > max_value)
                        max_value = mem_in[k];
                end
                golden[n] = max_value;
            end
        end
    endtask

    // ------------------------------------------------------------
    // Run one transaction
    // ------------------------------------------------------------

    integer errors;

    task run_once;
        integer cnt;

        begin

            // Start the HLS block.
            @(negedge clk);
            ap_start = 1'b1;

            @(negedge clk);

            cnt = 0;

            // Wait until HLS accepts the transaction.
            while (!ap_ready && cnt < 5000) begin
                @(negedge clk);
                cnt = cnt + 1;
            end

            if (!ap_ready) begin
                $display("TIMEOUT: ap_ready never came");
                errors = errors + 1;
            end

            // Prevent another transaction from starting.
            ap_start = 1'b0;

            // Wait until the block becomes idle again.
            cnt = 0;

            while (!ap_idle && cnt < 5000) begin
                @(negedge clk);
                cnt = cnt + 1;
            end

            if (!ap_idle) begin
                $display("TIMEOUT: ap_idle never came");
                errors = errors + 1;
            end

        end
    endtask

    // ------------------------------------------------------------
    // Main test
    // ------------------------------------------------------------

    integer t;
    integer n;

    reg [31:0] seed;

    initial begin

        errors = 0;
        seed   = 32'd12345;

        // --------------------------------------------------------
        // Reset
        // --------------------------------------------------------

        repeat (5) @(negedge clk);

        rst = 1'b0;

        repeat (2) @(negedge clk);

        // --------------------------------------------------------
        // Five different input vectors
        // --------------------------------------------------------

        for (t = 0; t < 5; t = t + 1) begin
            // ----------------------------------------------------
            // Generate input vector
            // ----------------------------------------------------
            for (n = 0; n < N_SAMPLES; n = n + 1) begin
                case (t)
                    // Test 0: increasing sequence
                    0:
                        mem_in[n] = n;
                    // Test 1: decreasing sequence
                    1:
                        mem_in[n] = N_SAMPLES - 1 - n;
                    // Test 2: alternating positive / negative
                    2:
                        if ((n % 2) == 0)
                            mem_in[n] = n * 10;
                        else
                            mem_in[n] = -n * 10;
                    // Test 3: constant value
                    3:
                        mem_in[n] = 42;
                    // Test 4: deterministic pseudo-random values
                    4: begin
                        seed = seed * 32'd1103515245 + 32'd12345;
                        mem_in[n] = (seed >> 16) % 1000;
                    end
                endcase

                // Marker value. If DUT does not write an output,
                // this value remains and the comparison will fail.
                mem_out[n] = 32'hDEADBEEF;

            end

            // ----------------------------------------------------
            // Calculate expected result
            // ----------------------------------------------------

            make_golden;

            // ----------------------------------------------------
            // Run DUT
            // ----------------------------------------------------

            run_once;

            // Give the output RAM a few cycles to settle.
            repeat (3) @(negedge clk);

            // ----------------------------------------------------
            // Compare
            // ----------------------------------------------------

            for (n = 0; n < N_SAMPLES; n = n + 1) begin
                if (mem_out[n] !== golden[n]) begin
                    errors = errors + 1;
                    if (errors <= 20) begin
                        $display(
                            "MISMATCH: test %0d, sample %0d: DUT=%0d, ref=%0d",
                            t,
                            n,
                            $signed(mem_out[n]),
                            $signed(golden[n])
                        );
                    end
                end
            end
        end

        // --------------------------------------------------------
        // Result
        // --------------------------------------------------------

        if (errors == 0)
            $display("Test passed !");
        else
            $display("Test FAILED: %0d errors", errors);

        $finish;

    end

    // ------------------------------------------------------------
    // Global timeout
    // ------------------------------------------------------------

    initial begin
        #500000;

        $display("TIMEOUT: simulation too long");
        $finish;
    end
endmodule
