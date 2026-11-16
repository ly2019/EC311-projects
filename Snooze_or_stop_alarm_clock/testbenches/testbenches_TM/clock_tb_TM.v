`timescale 1ns / 1ps

module clock_tb_TM;
    reg clk = 0, reset = 1, tick = 0;
    wire [3:0] hour1, hour0, minute1, minute0;

    clock uut(.clk(clk), .reset(reset), .tick(tick),
        .hour1(hour1), .hour0(hour0), .minute1(minute1), .minute0(minute0));

    always #5 clk = ~clk;

    initial begin
        #20;                         // Reset: 06:58:00 (seconds: uut.second).
        reset = 0; #20;              // No tick: time holds.
        tick = 1;                    // Each rising edge now represents a second.
        #590;                        // 06:58:59
        #10;                         // 06:59:00: seconds roll over.
        #600;                        // 07:00:00: minutes/hour carry.
        #611990;                     // 23:59:59
        #10;                         // 00:00:00: midnight rollover.
        tick = 0; #20;               // Hold at midnight.
        tick = 1; #30;               // 00:00:03
        reset = 1; #10;              // Reset overrides tick: 06:58:00.
        reset = 0; tick = 0; #10;
        $finish;
    end
endmodule
