`timescale 1ns / 1ps

module ticker_tb_TM;
    reg clk = 0;
    wire tick;

    // Four clock cycles per tick, for a short simulation.
    ticker #(.CLK_HZ(4), .TICK_HZ(1)) uut(.clk(clk), .tick(tick));

    always #5 clk = ~clk;

    initial begin
        #1;                          // Initial counter=0, tick=1.
        #9;                          // t=10: counter=1, tick=0.
        #20;                         // t=30: counter=3, tick=0.
        #10;                         // t=40: counter=0, tick=1.
        #10;                         // t=50: tick=0 (pulse lasts one cycle).
        #30;                         // t=80: next tick=1.
        #40;                         // t=120: next tick=1; spacing is 40 ns.
        $finish;
    end
endmodule
