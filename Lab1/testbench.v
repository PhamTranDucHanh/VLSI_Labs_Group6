`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2026 02:41:38 PM
// Design Name: 
// Module Name: testRingFlasher
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

module tb_ring_flasher;

    reg clk;
    reg reset_n;
    reg repeat_i;
    wire [15:0] led;

    // DUT
    Ring_Flasher uut (
        .clk(clk),
        .reset_n(reset_n),
        .repeat_i(repeat_i),
        .led(led)
    );
    // CLOCK 10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // TEST SEQUENCE
    initial begin
        // init
        reset_n = 0;
        repeat_i = 0;

        #20;
        reset_n = 1;

        #10;
        repeat_i = 1;
        #500;

        $stop;
    end
    // MONITOR
    initial begin
        $monitor("Time=%0t | state=%0d | idx=%0d | led=%b",
                  $time, uut.state, uut.idx, led);
    end

endmodule