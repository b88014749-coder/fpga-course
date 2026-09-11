`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/11/2026 10:32:40 AM
// Design Name: 
// Module Name: tb_lock_controller
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


module tb_lock_controller;
    logic        clk;
    logic        rst;
    logic  [3:0] digit_in;
    logic        unlocked_led;
    

    lock_controller dut (
        .clk(clk), 
        .rst(rst),
        .digit_in(digit_in), 
        .unlocked_led(unlocked_led)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic check_transition;
        input [3:0] digit_val;
        input [1:0] expected_state;
        input string step_name;
        begin
            digit_in = digit_val;
            @(posedge clk); #1;
            if (dut.state === expected_state)
                $display("PASS: %s -> state=%s(%0d)", step_name, dut.state.name(), dut.state);
            else
                $display("FAIL: %s -> expected %0d, got state=%s(%0d)", step_name, expected_state, dut.state.name(), dut.state);
        end
    endtask
    
    task automatic reset_state;
        rst = 1; 
        digit_in = '0;
        @(posedge clk); #1;
        rst = 0;
        $display("after reset: state=%s(%0d)", dut.state.name(), dut.state);
    endtask

    initial begin
        reset_state;
        check_transition(dut.DIGIT1 + 1, dut.LOCKED, "wrong digit1 pressed");    
    
        reset_state;
        check_transition(dut.DIGIT1,     dut.WAIT_D2, "correct digit1 pressed");
        check_transition(dut.DIGIT2 + 1, dut.LOCKED,  "wrong digit2 pressed");

        reset_state;
        check_transition(dut.DIGIT1,     dut.WAIT_D2, "correct digit1 pressed");
        check_transition(dut.DIGIT2,     dut.WAIT_D3, "correct digit2 pressed");
        check_transition(dut.DIGIT3 + 1, dut.LOCKED,  "wrong digit3 pressed");

        reset_state;
        check_transition(dut.DIGIT1, dut.WAIT_D2,  "correct digit1 pressed");
        check_transition(dut.DIGIT2, dut.WAIT_D3,  "correct digit2 pressed");
        check_transition(dut.DIGIT3, dut.UNLOCKED, "correct digit3 pressed");
        if (unlocked_led === 1'b1)
            $display("PASS: unlocked the lock");
        else
            $display("FAIL: to unlock the lock");

        $finish;
    end

endmodule
