`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2026 11:46:35 PM
// Design Name: 
// Module Name: counter
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


module counter
    #(parameter N=4)
(
    input logic clk,
    input logic reset,
    output logic [N-1:0] counter
    );
    logic [N-1:0] current_value;
    
    always_ff @(posedge clk, posedge reset)
        if (reset)
            current_value <= 0;
        else
            current_value <= current_value + 1'b1;
    
    assign counter = current_value;
endmodule
