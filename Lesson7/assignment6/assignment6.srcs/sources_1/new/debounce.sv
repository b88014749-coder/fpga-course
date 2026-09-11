`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/11/2026 12:42:08 PM
// Design Name: 
// Module Name: debounce
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


module debounce_filter #(
    parameter integer COUNT_MAX = 200_000
) (
    input  logic       clk,
    input  logic [3:0] digit_raw,
    output logic [3:0] digit_clean
);

    logic [17:0] counter;

    always_ff @(posedge clk) begin
        if (digit_raw != digit_clean) begin
            counter <= counter + 1;

            if (counter == COUNT_MAX - 1) begin
                digit_clean <= digit_raw;
                counter <= 0;
            end
        end
        else begin
            counter <= 0;
        end
    end

endmodule


