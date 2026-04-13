`timescale 1ns / 1ps
// HCMUT
// Authors: Duc Hanh, Gia Huy, Phuong Vu, Gia Hung, Minh Huan
//
// Create Date: 04/02/2026 03:10:10 PM
// Design Name:
// Module Name: ring_flasher
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Ring flasher module that toggles LEDs clockwise then counter-clockwise
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//

module ring_flasher(
  input  wire        clk,
  input  wire        reset_n,
  input  wire        repeat_i,
  output reg  [15:0] led
);

  // --------------------------------
  // PARAMETER
  // --------------------------------
  parameter IDLE       = 2'd0; // Idle state, waiting for repeat_i
  parameter TOGGLE_CW  = 2'd1; // Toggle LEDs clockwise
  parameter TOGGLE_CCW = 2'd2; // Toggle LEDs counter-clockwise

  // --------------------------------
  // INPUT/OUTPUT DECLARATION
  // (declared in port list above)
  // --------------------------------

  // --------------------------------
  // INTERNAL SIGNAL DECLARATION
  // --------------------------------
  // FF: current state register
  reg [1:0] state;
  // Combinational: next state logic
  reg [1:0] next_state;

  // FF: LED index counter
  reg [3:0] idx;
  // FF: step counter within each direction pass
  reg [3:0] step_cnt;
  // FF: cycle counter for full CW+CCW passes
  reg [3:0] cycle_cnt;

  // Combinational: previous index (wraps around)
  reg [3:0] prev_idx;

  // --------------------------------
  // STATE REGISTER (FF)
  // --------------------------------
  always @(posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  // --------------------------------
  // PREVIOUS INDEX LOGIC (Combinational)
  // --------------------------------
  always @(idx) begin
    if (idx == 4'd0) begin
      prev_idx = 4'd15;
    end else begin
      prev_idx = idx - 4'd1;
    end
  end

  // --------------------------------
  // NEXT STATE LOGIC (Combinational)
  // --------------------------------
  always @(state, repeat_i, step_cnt, cycle_cnt) begin
    next_state = state;

    case (state)
      IDLE: begin
        if (repeat_i == 1'b1) begin
          next_state = TOGGLE_CW;
        end
      end

      TOGGLE_CW: begin
        if (step_cnt == 4'd7) begin
          next_state = TOGGLE_CCW;
        end
      end

      TOGGLE_CCW: begin
        if (step_cnt == 4'd3) begin
          if (cycle_cnt == 4'd8) begin
            if (repeat_i == 1'b1) begin
              next_state = TOGGLE_CW;
            end else begin
              next_state = IDLE;
            end
          end else begin
            next_state = TOGGLE_CW;
          end
        end
      end

      default: begin
        next_state = IDLE;
      end
    endcase
  end

  // --------------------------------
  // DATAPATH / OUTPUT LOGIC (FF)
  // --------------------------------
  always @(posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0) begin
      led       <= 16'b0;
      idx       <= 4'd0;
      step_cnt  <= 4'd0;
      cycle_cnt <= 4'd1;
    end else begin

      case (state)

        // Idle: reset all registers
        IDLE: begin
          led       <= 16'b0;
          idx       <= 4'd0;
          step_cnt  <= 4'd0;
          cycle_cnt <= 4'd1;
        end

        // Clockwise: toggle LED at current index, advance index
        TOGGLE_CW: begin
          led[idx] <= ~led[idx];
          idx      <= idx + 4'd1;

          if (step_cnt == 4'd7) begin
            step_cnt <= 4'd0;
          end else begin
            step_cnt <= step_cnt + 4'd1;
          end
        end

        // Counter-clockwise: toggle LED at previous index, retreat index
        TOGGLE_CCW: begin
          led[prev_idx] <= ~led[prev_idx];
          idx           <= prev_idx;

          if (step_cnt == 4'd3) begin
            step_cnt  <= 4'd0;
            cycle_cnt <= cycle_cnt + 4'd1;

            if (cycle_cnt == 4'd8) begin
              cycle_cnt <= 4'd1;
            end
          end else begin
            step_cnt <= step_cnt + 4'd1;
          end
        end

        default: begin
          led       <= 16'b0;
          idx       <= 4'd0;
          step_cnt  <= 4'd0;
          cycle_cnt <= 4'd1;
        end

      endcase
    end
  end

endmodule