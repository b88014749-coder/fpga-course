`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
// 
// Create Date: 08/29/2026 06:57:39 PM
// Design Name: 
// Module Name: main4
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

//Tested on the PYNQ-Z1 board
module main4(
    input sysclk,
    input logic [3:0] btn,
    output logic [3:0] led
    );

    decoder #(.WIDTH(4)) dec(.sel(btn[1:0]), .out(led));
endmodule
