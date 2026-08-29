`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2026 09:22:36 PM
// Design Name: 
// Module Name: decoder_test
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


module decoder_test(
    input  logic [1:0] sel2,
    output logic [3:0] out4,
    input  logic [2:0] sel3,
    output logic [7:0] out8
);

    decoder #(.WIDTH(4)) dec4 (
        .sel(sel2),
        .out(out4)
    );

    decoder #(.WIDTH(8)) dec8 (
        .sel(sel3),
        .out(out8)
    );

endmodule