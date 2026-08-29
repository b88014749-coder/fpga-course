`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2026 07:14:08 PM
// Design Name: 
// Module Name: decoder
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


module decoder
    #(parameter WIDTH = 4)
(
    input logic [$clog2(WIDTH)-1:0] sel,
    output logic [WIDTH-1:0] out
    );
    assign out = WIDTH'(1) << sel;
endmodule
