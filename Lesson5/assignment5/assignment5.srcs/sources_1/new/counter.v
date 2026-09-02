`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2026 07:32:33 PM
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


module counter(
  input  wire       clk,
  input  wire       rst,    //asynchronous reset, active high
  input  wire       load,   //synchronous load
  input  wire [3:0] data_in,//load value
  input  wire       en,     //enable counter
  input  wire       up_down,//1 -> up, 0 <- down
  output reg  [3:0] count   //current value
    );
    
    always @(posedge rst, posedge clk) begin
        if (rst)
            count <= 'b0;
        else if (load)
            count <= data_in;
        else if (en) begin
            if (up_down)
                count <= count + 1;
            else
                count <= count - 1;
        end
    end
endmodule
