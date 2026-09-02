`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2026 08:47:29 PM
// Design Name: 
// Module Name: tb_counter
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


module tb_counter;
    reg clk;
    reg rst;
    reg load;
    reg [3:0] data_in;
    reg en;
    reg up_down;
    wire [3:0] count;
   
    counter dut(.clk(clk), .rst(rst), .load(load),
                .data_in(data_in), .en(en), .up_down(up_down),
                .count(count));
   
    initial clk = 0;
    always #1 clk = ~clk;

    task automatic check_count;
        input [3:0] expected;
        input string msg;
        begin
            if (count === expected)
                $display("[Test (%s)] PASS: expected=%0d -> result=%0d", msg, expected, count);
            else
                $display("[Test (%s)] FAIL: expected=%0d -> result=%0d", msg, expected, count);
        end
    endtask

    initial begin
    #1;   //Introduced the delay for the sub task 9, to show the X state on the wave form prior to the reset
    //The count is in X state prior to the reset as it is not initialized yet and it is state is unknown,
    //in other words it is in neither of the following states (0,1,Z)
    rst = 1;
    #1;
    rst = 0;
    #1;
    load=1; data_in=4'd10;
    @(posedge clk); #1;
    load=0;
    check_count(10, "3");
 
    en=1;up_down=1;
    @(posedge clk); #1;
    @(posedge clk); #1;
    @(posedge clk); #1;
    check_count(13, "4.1");
   
    @(posedge clk); #1;
    @(posedge clk); #1;
    @(posedge clk); #1;
    check_count(0, "4.2");
    
    en=0;
    @(posedge clk); #1;
    @(posedge clk); #1;
    check_count(0, "5");
        
    en=1; up_down=0;
    @(posedge clk); #1;
    check_count(15, "6");
        
    load=1; data_in=4'd5; en=1; up_down=1;
    @(posedge clk); #1;
    check_count(5, "7");
    
    load=1; data_in=4'd8;
    @(posedge clk); #1;
    load=0; en=1; up_down=0;
    @(posedge clk); #1;
    check_count(7, "BONUS");
      
    $finish;
    end
endmodule
