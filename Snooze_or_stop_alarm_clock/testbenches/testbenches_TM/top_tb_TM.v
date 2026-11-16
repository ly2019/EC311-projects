`timescale 1ns / 1ps

module top_tb_TM;
    reg clk = 0;
    reg [3:0] button = 4'b1000;
    wire led, dp;
    wire [6:0] seg;
    wire [7:0] an;

    top uut(.clk(clk), .button(button), .led(led), .seg(seg), .an(an), .dp(dp));

    // One simulated second every 20 ms. Keep real button debouncing.
    defparam uut.ticker.CLK_HZ = 2000000;

    always #5 clk = ~clk;

    initial begin
        // button = {reset, trigger, stop, snooze}.
        #20;                         // Reset: clock=06:58, led=0, snooze_cnt=0.
        button = 4'b0000; #20;
        button = 4'b0100; #100;      // Short trigger rejected: led=0.
        button = 4'b0000; #20;
        button = 4'b0100; #10000030; // Valid trigger: BUZZ_1, led=1.
        button = 4'b0000; #20;       // Alarm stays on after release.
        button = 4'b0001; #10000030; // Snooze: led=0, snooze_cnt=1, timer=00:10.
        button = 4'b0000; #20;       // Waiting; timer_en pulse has finished.
        #20000000;                   // One tick later: timer=00:09.
        button = 4'b0010; #10000030; // Stop while waiting: IDLE, led=0.
        button = 4'b0000; #20;
        button = 4'b1000; #20;       // Reset: clock=06:58, snooze_cnt=0.
        $finish;
    end
endmodule
