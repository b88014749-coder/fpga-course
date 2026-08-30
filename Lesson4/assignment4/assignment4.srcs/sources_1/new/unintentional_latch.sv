`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2026 11:54:16 AM
// Design Name: 
// Module Name: unintentional_latch
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


module unintentional_latch(
    input logic sel,
    output logic out,
    input logic [1:0] in
    );
    always_comb begin
        case (sel)
            1'b1: out = in[0];
            default: out = in[1];
        endcase
    end
endmodule
