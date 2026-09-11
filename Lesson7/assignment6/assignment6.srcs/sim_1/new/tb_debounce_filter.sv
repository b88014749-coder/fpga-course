`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/11/2026 01:52:21 PM
// Design Name: 
// Module Name: tb_debounce_filter
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
module tb_debounce_filter;

    logic clk;
    logic [3:0] digit_raw;
    logic [3:0] digit_clean;

    debounce_filter #(
        .COUNT_MAX(5)
    ) dut (
        .clk(clk),
        .digit_raw(digit_raw),
        .digit_clean(digit_clean)
    );

    task automatic test_digit(input logic [3:0] digit_val, input integer delay_time);
        begin
            digit_raw = digit_val;
            #delay_time;
    
            $display("digit_raw = %0d, digit_clean = %0d",
                     digit_raw, digit_clean);
        end
    endtask
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        digit_clean = '0;
        test_digit(4'd0, 20);

        // Simulate bouncing when pressing "5"
        test_digit(4'd5, 7);
        test_digit(4'd0, 6);
        test_digit(4'd5, 8);
        test_digit(4'd0, 5);
        test_digit(4'd5, 100);
    
        // Simulate releasing/bouncing
        test_digit(4'd0, 6);
        test_digit(4'd5, 5);
        test_digit(4'd0, 7);
        test_digit(4'd5, 5);
        test_digit(4'd0, 100);
        
        $finish;
    end

endmodule
