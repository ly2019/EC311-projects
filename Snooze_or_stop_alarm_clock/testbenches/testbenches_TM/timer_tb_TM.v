`timescale 1ns / 1ps

module timer_tb_TM;
    reg clk = 0, tick = 0, timer_en = 0;
    reg [1:0] snooze_cnt = 0;
    wire timeout;
    wire [3:0] m1, m0, s1, s0;

    timer uut(.clk(clk), .tick(tick), .timer_en(timer_en),
        .snooze_cnt(snooze_cnt), .timeout(timeout),
        .m1(m1), .m0(m0), .s1(s1), .s0(s0));

    always #5 clk = ~clk;

    initial begin
        #20;                         // Initial digits: 00:00, timeout=0.
        snooze_cnt = 1; timer_en = 1; tick = 1;
        #10;                         // Load beats tick: 00:10.
        timer_en = 0; tick = 0;
        #20;                         // No tick: hold 00:10.
        tick = 1; #10;               // 00:09: decimal digit rollover.
        #80;                         // 00:01, timeout=1 while tick=1.
        tick = 0; #10;               // Hold 00:01, timeout=0.
        tick = 1; #1;                // Timeout asserts BEFORE next clock edge.
        #9;                          // 00:00, timeout=0 after that edge.
        #20;                         // Stay at zero; no underflow.
        snooze_cnt = 2; timer_en = 1;
        #10;                         // Second snooze loads 00:05.
        timer_en = 0; #40;           // 00:01, timeout=1.
        #10;                         // 00:00, timeout=0.
        timer_en = 1; #10;           // Reload 00:05.
        timer_en = 0; #10;           // 00:04.
        snooze_cnt = 0; #10;         // Clear on tick: 00:00.
        snooze_cnt = 3; timer_en = 1;
        #10;                         // Unsupported snooze count loads zero.
        $finish;
    end
endmodule
