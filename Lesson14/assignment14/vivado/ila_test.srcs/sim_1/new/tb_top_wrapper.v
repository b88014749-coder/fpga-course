`timescale 1ns / 1ps

module tb_top_wrapper;

    reg sys_clock = 0;
    reg ext_reset_in_0 = 0;

    tri [3:0] btn_tri_i_bidir;
    reg [3:0] btn_tri_i;

    tri [1:0] sw_tri_i_bidir;
    reg [1:0] sw_tri_i;

    tri [3:0] led_tri_io;

    reg [3:0] stopped_led;

    assign btn_tri_i_bidir = btn_tri_i;
    assign sw_tri_i_bidir  = sw_tri_i;


    // ============================================================
    // DUT
    // ============================================================

    design_microblaze_wrapper dut (
        .sys_clock      (sys_clock),
        .ext_reset_in_0 (ext_reset_in_0),
        .btn_tri_i      (btn_tri_i_bidir),
        .led_tri_io     (led_tri_io),
        .sw_tri_i       (sw_tri_i_bidir)
    );


    // ============================================================
    // 100 MHz clock
    // ============================================================

    always #5 sys_clock = ~sys_clock;


    // ============================================================
    // TESTS
    // ============================================================

    initial begin

        btn_tri_i = 4'b0000;
        sw_tri_i  = 2'b00;


        // ========================================================
        // Reset
        // ========================================================

        ext_reset_in_0 = 0;
        #200;
        ext_reset_in_0 = 1;


        // Wait for MicroBlaze to start
        #25_000;


        // ========================================================
        // TEST 1: DIRECTION
        // ========================================================

        $display("");
        $display("==============================================");
        $display("TEST 1: DIRECTION");
        $display("==============================================");


        // --------------------------------------------------------
        // LEFT
        // 0001 -> 0010
        // --------------------------------------------------------

        sw_tri_i = 2'b00;

        if (led_tri_io == 4'b0001)
            $display("PASS: Initial LED = 0001");
        else
            $display("FAIL: Initial LED = %b", led_tri_io);


        @(led_tri_io);


        if (led_tri_io == 4'b0010)
            $display("PASS: LEFT  0001 -> 0010");
        else
            $display("FAIL: LEFT expected 0010, got %b", led_tri_io);


        // --------------------------------------------------------
        // RIGHT
        // 0010 -> 0001
        // --------------------------------------------------------

        sw_tri_i = 2'b01;

        @(led_tri_io);


        if (led_tri_io == 4'b0001)
            $display("PASS: RIGHT 0010 -> 0001");
        else
            $display("FAIL: RIGHT expected 0001, got %b", led_tri_io);


        // ========================================================
        // TEST 2: STOP
        // ========================================================

        $display("");
        $display("==============================================");
        $display("TEST 2: STOP");
        $display("==============================================");


        // Press STOP
        btn_tri_i = 4'b0100;

        // Hold for the debouncing to do its job
        #50_000;

        // Release
        btn_tri_i = 4'b0000;

        // Give the button handler time to process the release
        #50_000;

        // Save LED after STOP
        stopped_led = led_tri_io;

        // Wait for several LED periods
        #30_000;

        // LED should still be unchanged
        if (led_tri_io == stopped_led)
            $display("PASS: STOP");
        else
            $display("FAIL: STOP - LED changed from %b to %b",
                     stopped_led, led_tri_io);


        // ========================================================
        // TEST 3: START
        // ========================================================

        $display("");
        $display("==============================================");
        $display("TEST 3: START");
        $display("==============================================");

        // Press START
        btn_tri_i = 4'b1000;

        // Hold for the debouncing to do its job
        #50_000;

        // Release
        btn_tri_i = 4'b0000;

        // Give the button handler time to process the release
        #50_000;

        // Wait for the LED to move
        #30_000;

        // LED should have changed
        if (led_tri_io != stopped_led)
            $display("PASS: START - LED changed from %b to %b",
                     stopped_led, led_tri_io);
        else
            $display("FAIL: START - LED did not change");


        // ========================================================
        // FINISH
        // ========================================================

        $display("");
        $display("==============================================");
        $display("TESTS COMPLETE");
        $display("==============================================");

        $finish;

    end

endmodule
