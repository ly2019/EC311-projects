`timescale 1ns / 1ps

module timer_testbench();
    reg clk, timer_en, tick;
    reg [1:0] snooze_cnt;
    wire timeout;
    wire [3:0] m1, m0, s1, s0;
    integer errors = 0;

    timer system_under_test(.clk(clk), .timer_en(timer_en), .tick(tick),
        .snooze_cnt(snooze_cnt), .timeout(timeout),
        .m1(m1), .m0(m0), .s1(s1), .s0(s0));

    initial clk = 0;
    always #5 clk = ~clk;

    task check_timer;
        input integer seconds_left;
        input expected_timeout;
        reg [3:0] em1, em0, es1, es0;
        begin
            em1 = seconds_left / 600; em0 = (seconds_left / 60) % 10;
            es1 = (seconds_left % 60) / 10; es0 = seconds_left % 10;
            if ({m1,m0,s1,s0} !== {em1,em0,es1,es0} ||
                system_under_test.time_remain !== seconds_left ||
                timeout !== expected_timeout) begin
                $display("FAIL timer at %0t: expected %0d seconds, timeout=%b; got %0d%0d:%0d%0d, timeout=%b",
                    $time, seconds_left, expected_timeout, m1,m0,s1,s0,timeout);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        timer_en = 0; tick = 0; snooze_cnt = 0;
        #10;
        check_timer(0, 0);
        timer_en = 1; snooze_cnt = 1;
        #10; // First snooze loads 05:00 without needing tick.
        check_timer(300, 0);
        tick = 1;
        #20; // timer_en reloads each cycle and wins over tick.
        check_timer(300, 0);
        timer_en = 0; tick = 0;
        #30; // Hold between ticks.
        check_timer(300, 0);
        tick = 1;
        #10;
        check_timer(299, 0); // 05:00 -> 04:59.
        repeat (298) #10;
        check_timer(1, 1); // Timeout is high during the final tick interval.
        tick = 0;
        #10;
        check_timer(1, 0); // Timeout is gated by tick, not latched.
        tick = 1;
        #1; // Before the next rising edge: request timeout at one second.
        check_timer(1, 1);
        #9;
        check_timer(0, 0);
        #20;
        check_timer(0, 0); // Saturate at zero; no underflow.

        tick = 0; timer_en = 1; snooze_cnt = 2;
        #10;
        check_timer(180, 0); // Second snooze loads 03:00.
        timer_en = 0; tick = 1;
        #10;
        check_timer(179, 0);
        repeat (119) #10;
        check_timer(60, 0);
        #10;
        check_timer(59, 0); // 01:00 -> 00:59.
        repeat (58) #10;
        check_timer(1, 1);
        #10;
        check_timer(0, 0);

        timer_en = 1; tick = 0; snooze_cnt = 1;
        #10;
        check_timer(300, 0);
        timer_en = 0; snooze_cnt = 0;
        #10;
        check_timer(300, 0); // Clearing snooze_cnt alone waits for tick.
        tick = 1;
        #10;
        check_timer(0, 0);
        timer_en = 1; snooze_cnt = 3;
        #10;
        check_timer(0, 0); // Unsupported snooze selection loads zero.

        if (errors != 0) $fatal(1, "timer_testbench: %0d failure(s)", errors);
        $display("PASS timer_testbench");
        $finish;
    end
endmodule
