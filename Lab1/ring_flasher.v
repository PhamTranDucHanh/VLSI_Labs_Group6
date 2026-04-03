`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// HCMUT 
// Authors: Duc Hanh, Gia Huy, Phuong Vu, Gia Hung, Minh Huan
// 
// Create Date: 04/02/2026 03:10:10 PM
// Design Name: 
// Module Name: ring_flasher
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
module Ring_Flasher(
    input  wire        clk,
    input  wire        reset_n,
    input  wire        repeat_i,
    output reg [15:0]  led
);

    //--------------------------------
    // STATE
    //--------------------------------
    parameter IDLE        = 2'd0;
    parameter TOGGLE_CW   = 2'd1;
    parameter TOGGLE_CCW  = 2'd2;

    reg [1:0] state, next_state;

    //--------------------------------
    // INTERNAL SIGNALS
    //--------------------------------
    reg [3:0] idx;
    reg [3:0] step_cnt;
    reg [3:0] cycle_cnt;

    //--------------------------------
    // STATE REGISTER
    //--------------------------------
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    //--------------------------------
    // NEXT STATE
    //--------------------------------
    always @(*) begin
        next_state = state;

        case (state)
            IDLE:
                if (repeat_i)
                    next_state = TOGGLE_CW;

            TOGGLE_CW:
                if (step_cnt == 4'd7)
                    next_state = TOGGLE_CCW;

            TOGGLE_CCW:
                if (step_cnt == 4'd3) begin
                    if (cycle_cnt == 4'd8) begin
                        if (repeat_i) begin
                            next_state = TOGGLE_CW;
                            cycle_cnt = 4'd0;
                        end
                        else
                            next_state = IDLE;
                    end
                    else
                        next_state = TOGGLE_CW;
                end

        endcase
    end

    //--------------------------------
    // DATAPATH
    //--------------------------------
    wire [3:0] prev_idx = (idx == 0) ? 4'd15 : idx - 1;

    //--------------------------------
    // MAIN LOGIC
    //--------------------------------
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            led       <= 16'b0;
            idx       <= 4'd0;
            step_cnt  <= 4'd0;
            cycle_cnt <= 4'd1;
        end else begin

            case (state)

                //--------------------------------
                //IDLE
                //--------------------------------
                IDLE: begin
                    led       <= 16'b0;
                    idx       <= 4'd0;
                    step_cnt  <= 4'd0;
                    cycle_cnt <= 4'd1;
                end

                //--------------------------------
                // CW
                //--------------------------------
                TOGGLE_CW: begin
                    led[idx] <= ~led[idx]; 

                    idx      <= idx + 1;
                    step_cnt <= step_cnt + 1;

                    if (step_cnt == 4'd7)
                        step_cnt <= 0;
                end

                //--------------------------------
                // CCW
                //--------------------------------
                TOGGLE_CCW: begin
                    led[prev_idx] <= ~led[prev_idx];

                    idx      <= prev_idx;
                    step_cnt <= step_cnt + 1;

                    if (step_cnt == 4'd3) begin
                        step_cnt <= 0;
                        cycle_cnt <= cycle_cnt + 1;
                    end
                end


            endcase
        end
    end

endmodule