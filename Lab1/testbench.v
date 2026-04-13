`timescale 1ns / 1ps
// HCMUT
// Authors: Duc Hanh, Gia Huy, Phuong Vu, Gia Hung, Minh Huan
//
// Create Date: 04/02/2026 02:41:38 PM
// Design Name:
// Module Name: tb_ring_flasher
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Testbench for ring_flasher module
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//

module tb_ring_flasher;

  // --------------------------------
  // PARAMETER
  // --------------------------------
  parameter CLK_HALF_PERIOD = 5;   // Half period of clock: 5ns => 10ns period
  parameter RST_DEASSERT    = 20;  // Duration of reset assertion
  parameter REPEAT_ON_1     = 10;  // Delay before first repeat assertion
  parameter REPEAT_DUR_1    = 1050; // Duration of first repeat_i high
  parameter REPEAT_DUR_2    = 1070; // Delay before second repeat_i
  parameter REPEAT_DUR_3    = 10;  // Duration of second repeat_i high
  parameter IDLE_WAIT       = 200; // Wait before mid-test reset
  parameter RST_PULSE       = 20;  // Duration of mid-test reset
  parameter RST_RECOVER     = 30;  // Recovery time after mid-test reset
  parameter REPEAT_DUR_4    = 20;  // Duration of third repeat_i high
  parameter SIM_END_WAIT    = 3000; // Simulation end wait

  // --------------------------------
  // SIGNAL DECLARATION
  // --------------------------------
  reg         clk;
  reg         reset_n;
  reg         repeat_i;
  wire [15:0] led;

  // --------------------------------
  // DUT INSTANTIATION
  // --------------------------------
  ring_flasher ring_flasher_01 (
    .clk     (clk),
    .reset_n (reset_n),
    .repeat_i(repeat_i),
    .led     (led)
  );

  // --------------------------------
  // CLOCK GENERATION
  // Clock starts low, first rising edge at CLK_HALF_PERIOD (not at time 0)
  // --------------------------------
  initial begin
    clk = 1'b0;
    forever #CLK_HALF_PERIOD clk = ~clk;
  end

  // --------------------------------
  // TEST SEQUENCE
  // Covers: reset, basic repeat operation, mid-test reset, corner cases
  // --------------------------------
  initial begin
    // Initialize inputs, apply reset
    reset_n  = 1'b0;
    repeat_i = 1'b0;

    // Release reset
    #RST_DEASSERT;
    reset_n = 1'b1;

    // Test case 1: Normal repeat operation, repeat_i held long enough
    #REPEAT_ON_1;
    repeat_i = 1'b1;

    #REPEAT_DUR_1;
    repeat_i = 1'b0;

    // Test case 2: repeat_i pulse after first sequence ends
    #REPEAT_DUR_2;
    repeat_i = 1'b1;

    #REPEAT_DUR_3;
    repeat_i = 1'b0;

    // Test case 3: Mid-operation reset
    #IDLE_WAIT;
    reset_n = 1'b0;

    #RST_PULSE;
    reset_n = 1'b1;

    // Test case 4: Short repeat_i pulse after reset
    #RST_RECOVER;
    repeat_i = 1'b1;

    #REPEAT_DUR_4;
    repeat_i = 1'b0;

    // Wait for simulation to settle
    #SIM_END_WAIT;

    $stop;
    $finish;
  end

  // --------------------------------
  // MONITOR
  // --------------------------------
  initial begin
    $monitor("Time=%0t | state=%0d | idx=%0d | led=%b",
             $time, ring_flasher_01.state, ring_flasher_01.idx, led);
  end

  // --------------------------------
  // WAVEFORM DUMP
  // --------------------------------
  initial begin
    $recordfile("waves");
    $recordvars("depth=0", tb_ring_flasher);
  end

endmodule