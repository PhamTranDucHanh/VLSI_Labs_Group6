`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2026 02:11:48 PM
// Design Name: 
// Module Name: Ring_Flasher
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

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2026 02:11:48 PM
// Design Name: 
// Module Name: Ring_Flasher
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
    input  logic        clk,
    input  logic        reset_n,
    input  logic        repeat_i,
    output logic [15:0] led
);

    //--------------------------------
    // STATE DEFINITION
    //--------------------------------
    typedef enum logic [2:0] {
        IDLE,
        ON_CW,
        OFF_CCW,
        TOGGLE_CW,
        TOGGLE_CCW,
        DONE
    } state_t;

    state_t state, next_state;

    //--------------------------------
    // INTERNAL SIGNALS
    //--------------------------------
    logic [4:0] idx;
    logic [3:0] step_cnt;
    logic [1:0] cycle_cnt;

    //--------------------------------
    // STATE REGISTER
    //--------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    //--------------------------------
    // NEXT STATE LOGIC
    //--------------------------------
    always_comb begin
        next_state = state;

        case (state)
            IDLE:
                if (repeat_i) begin
                    next_state = ON_CW;
                end

            //--------------------------------
            ON_CW:
                if (step_cnt == 7)
                    next_state = OFF_CCW;

            //--------------------------------
            OFF_CCW:
                if (step_cnt == 3) begin
                    if (cycle_cnt == 2)
                        next_state = TOGGLE_CW;
                    else
                        next_state = ON_CW;
                end

            //--------------------------------
            TOGGLE_CW:
                if (step_cnt == 7)
                    next_state = TOGGLE_CCW;

            //--------------------------------
            TOGGLE_CCW:
                if (step_cnt == 3) begin
                    if (led == 16'b0)
                        next_state = DONE;
                    else
                        next_state = TOGGLE_CW;
                end

            //--------------------------------
            DONE:
                if (repeat_i)
                    next_state = ON_CW;
                else
                    next_state = IDLE;
        endcase
    end

    //--------------------------------
    // DATAPATH + OUTPUT
    //--------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            led       <= 16'b0;
            idx       <= 4'd0;
            step_cnt  <= 4'd0;
            cycle_cnt <= 2'd0;
        end else begin

            case (state)

                //--------------------------------
                IDLE: begin
                    led       <= 16'b0;
                    idx       <= 4'd0;
                    step_cnt  <= 4'd0;
                    cycle_cnt <= 2'd0;
                end

                //--------------------------------
                // TURN ON (CW)
                //--------------------------------
                ON_CW: begin
                    led[idx] <= 1'b1;
                    idx      <= idx + 1;
                    step_cnt <= step_cnt + 1;

                    if (step_cnt == 7) begin
                        step_cnt <= 0;
                    end
                end

                //--------------------------------
                // TURN OFF (CCW)
                //--------------------------------
                OFF_CCW: begin
                    led[idx-1] <= 1'b0;   // FIX l?ch idx
                    idx        <= idx - 1;
                    step_cnt   <= step_cnt + 1;

                    if (step_cnt == 3) begin
                        step_cnt  <= 0;
                        cycle_cnt <= cycle_cnt + 1;
                    end
                end

                //--------------------------------
                // TOGGLE (CW)
                //--------------------------------
                TOGGLE_CW: begin
                    led[idx] <= ~led[idx];
                    idx      <= idx + 1;
                    step_cnt <= step_cnt + 1;

                    if (step_cnt == 7) begin
                        step_cnt <= 0;
                    end
                end

                //--------------------------------
                // TOGGLE (CCW)
                //--------------------------------
                TOGGLE_CCW: begin
                    led[idx-1] <= ~led[idx-1];  // FIX l?ch idx
                    idx        <= idx - 1;
                    step_cnt   <= step_cnt + 1;

                    if (step_cnt == 3) begin
                        step_cnt <= 0;
                    end
                end

                //--------------------------------
                DONE: begin
                    led <= 16'b0;
                end

            endcase
        end
    end

endmodule