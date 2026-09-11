`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/11/2026 09:23:50 AM
// Design Name: 
// Module Name: lock_controller
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


module lock_controller(
     input  clk,
     input  rst, //active high
     input  [3:0] digit_in,
     output unlocked_led //1 -> unlocked
    );
    typedef enum logic [1:0] {LOCKED, WAIT_D2, WAIT_D3, UNLOCKED} state_t;
    state_t state, next_state;

    localparam [3:0] DIGIT1 = 4'd5;
    localparam [3:0] DIGIT2 = 4'd3;
    localparam [3:0] DIGIT3 = 4'd7;

    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            state <= LOCKED;
        else
            state <= next_state;
    end
    
    always_comb begin
        next_state = state;
        case (state)
            LOCKED: next_state = (digit_in == DIGIT1) ? WAIT_D2 : LOCKED;
            WAIT_D2: next_state = (digit_in == DIGIT2) ? WAIT_D3 : LOCKED;
            WAIT_D3: next_state = (digit_in == DIGIT3) ? UNLOCKED : LOCKED;
            UNLOCKED: next_state = UNLOCKED;
            default: next_state =  LOCKED;
        endcase
    end
    
    assign unlocked_led = state == UNLOCKED;
endmodule
