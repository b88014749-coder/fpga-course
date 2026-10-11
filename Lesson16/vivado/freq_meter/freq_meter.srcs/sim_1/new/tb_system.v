`timescale 1ns / 1ps

module tb_system;

    // Testbench signals
    reg sysclk;
    reg reset_rtl;
    reg sig_in;

    // Instantiate the design wrapper
    design_1_wrapper dut (
        .sysclk    (sysclk),
        .reset_rtl (reset_rtl),
        .sig_in    (sig_in)
    );

    // 125 MHz system clock on Pynq Z1 board: period = 8 ns
    initial begin
        sysclk = 1'b0;
        forever #4 sysclk = ~sysclk;
    end

    // Reset sequence
    initial begin
        reset_rtl = 1'b0;
        #200;
        reset_rtl = 1'b1;
    end

    // Generate sig_in with a period of 1 us (1 MHz).
    initial begin
        sig_in = 1'b0;
    
        // Wait until reset is released
        wait (reset_rtl == 1'b1);
        @(posedge sysclk);
    
        forever begin
            #500;
            sig_in = ~sig_in;
        end
    end
    
    // End simulation after sufficient time
    initial begin
        #50000;
        $finish;
    end

endmodule
