`timescale 1ns / 1ps

module alarm_fsm_tb_TM;
    reg clk = 0, reset = 1;
    reg trigger = 0, snooze = 0, stop = 0, timeout = 0;
    wire [1:0] snooze_cnt;
    wire timer_en, buzz;

    alarm_fsm uut(.clk(clk), .reset(reset), .trigger(trigger),
        .snooze(snooze), .stop(stop), .timeout(timeout),
        .snooze_cnt(snooze_cnt), .timer_en(timer_en), .buzz(buzz));

    always #5 clk = ~clk;

    initial begin
        // Expected outputs below: {buzz, timer_en, snooze_cnt}.
        
        #20;                         // IDLE: 0000
        reset = 0; #20;              // Stay idle without trigger.
        trigger = 1; #10;            // BUZZ_1: 1000
        trigger = 0; #20;            // Keep buzzing.
        snooze = 1; #10;             // SNOOZE_1: 0101 (load for one cycle)
        snooze = 0; #10;             // SNOOZE_1_WAITING: 0001
        #20;                         // Wait without timeout.

        timeout = 1; #10;            // BUZZ_2: 1001
        timeout = 0; #20;
        snooze = 1; #10;             // SNOOZE_2: 0110 (load for one cycle)
        snooze = 0; #10;             // SNOOZE_2_WAITING: 0010
        #20;

        timeout = 1; #10;            // FINAL_BUZZ: 1010
        timeout = 0;
        snooze = 1; #20;             // Third snooze ignored: still FINAL_BUZZ.
        snooze = 0;
        stop = 1; #10;               // IDLE: 0000
        stop = 0;
        trigger = 1; #10;            // Re-arm: BUZZ_1.
        trigger = 0;
        stop = 1; snooze = 1; #10;   // Stop wins over snooze: IDLE.
        stop = 0; snooze = 0;
        trigger = 1; #10;
        trigger = 0;
        reset = 1; #10;              // Reset while buzzing: IDLE.
        $finish;
    end
endmodule
