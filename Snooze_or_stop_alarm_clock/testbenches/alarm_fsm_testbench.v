`timescale 1ns / 1ps

module alarm_fsm_testbench();
    reg clk, reset, trigger, snooze, stop, timeout;
    wire [1:0] snooze_cnt;
    wire timer_en, buzz;
    integer errors = 0;
    integer target;

    localparam IDLE = 8'h01, BUZZ_1 = 8'h02, SNOOZE_1 = 8'h04,
        WAIT_1 = 8'h08, BUZZ_2 = 8'h10, SNOOZE_2 = 8'h20,
        WAIT_2 = 8'h40, FINAL_BUZZ = 8'h80;

    alarm_fsm system_under_test(.clk(clk), .reset(reset), .trigger(trigger),
        .snooze(snooze), .stop(stop), .timeout(timeout),
        .snooze_cnt(snooze_cnt), .timer_en(timer_en), .buzz(buzz));

    initial clk = 0;
    always #5 clk = ~clk;

    task check_state;
        input [7:0] expected_state;
        input expected_buzz, expected_enable;
        input [1:0] expected_count;
        begin
            if (system_under_test.state !== expected_state ||
                {buzz,timer_en,snooze_cnt} !==
                {expected_buzz,expected_enable,expected_count}) begin
                $display("FAIL FSM at %0t: expected state=%h outputs=%b%b%b; got state=%h outputs=%b%b%b",
                    $time, expected_state, expected_buzz, expected_enable, expected_count,
                    system_under_test.state, buzz, timer_en, snooze_cnt);
                errors = errors + 1;
            end
        end
    endtask

    // Reach any of the eight states from reset, using timed button pulses.
    // Also check every intermediate state and its Moore outputs.
    task reach_state;
        input integer index;
        begin
            reset = 1; trigger = 0; snooze = 0; stop = 0; timeout = 0;
            #10;
            reset = 0;
            check_state(IDLE, 0, 0, 0);
            if (index >= 1) begin
                trigger = 1; #10; trigger = 0;
                check_state(BUZZ_1, 1, 0, 0);
            end
            if (index >= 2) begin
                snooze = 1; #10; snooze = 0;
                check_state(SNOOZE_1, 0, 1, 1);
            end
            if (index >= 3) begin
                #10;
                check_state(WAIT_1, 0, 0, 1);
            end
            if (index >= 4) begin
                timeout = 1; #10; timeout = 0;
                check_state(BUZZ_2, 1, 0, 1);
            end
            if (index >= 5) begin
                snooze = 1; #10; snooze = 0;
                check_state(SNOOZE_2, 0, 1, 2);
            end
            if (index >= 6) begin
                #10;
                check_state(WAIT_2, 0, 0, 2);
            end
            if (index >= 7) begin
                timeout = 1; #10; timeout = 0;
                check_state(FINAL_BUZZ, 1, 0, 2);
            end
        end
    endtask

    initial begin
        reset = 1; trigger = 0; snooze = 0; stop = 0; timeout = 0;
        #10;
        reach_state(0);
        snooze = 1; timeout = 1; stop = 1;
        #20; // IDLE ignores inputs other than trigger and reset.
        check_state(IDLE, 0, 0, 0);

        reach_state(1);
        #20;
        check_state(BUZZ_1, 1, 0, 0);
        snooze = 1; stop = 1;
        #10; // Stop wins over snooze in first buzz.
        check_state(IDLE, 0, 0, 0);

        reach_state(3);
        trigger = 1; snooze = 1;
        #20; // Waiting ignores trigger and snooze.
        check_state(WAIT_1, 0, 0, 1);
        stop = 1; timeout = 1;
        #10; // Stop wins over timeout.
        check_state(IDLE, 0, 0, 0);

        reach_state(4);
        #20;
        check_state(BUZZ_2, 1, 0, 1);
        stop = 1; snooze = 1;
        #10;
        check_state(IDLE, 0, 0, 0);

        reach_state(6);
        trigger = 1; snooze = 1;
        #20;
        check_state(WAIT_2, 0, 0, 2);
        stop = 1; timeout = 1;
        #10;
        check_state(IDLE, 0, 0, 0);

        reach_state(7); // Full first-snooze / second-snooze / final-buzz path.
        trigger = 1; snooze = 1; timeout = 1;
        #30; // A third snooze is ignored.
        check_state(FINAL_BUZZ, 1, 0, 2);
        stop = 1;
        #10;
        check_state(IDLE, 0, 0, 0);

        // The two load states always last one cycle, even with stop asserted.
        reach_state(2);
        stop = 1;
        #10;
        check_state(WAIT_1, 0, 0, 1);
        #10;
        check_state(IDLE, 0, 0, 0);
        reach_state(5);
        stop = 1;
        #10;
        check_state(WAIT_2, 0, 0, 2);
        #10;
        check_state(IDLE, 0, 0, 0);

        // Reset has priority from every reachable state.
        for (target = 0; target < 8; target = target + 1) begin
            reach_state(target);
            reset = 1; trigger = 1; snooze = 1; stop = 1; timeout = 1;
            #10;
            check_state(IDLE, 0, 0, 0);
        end

        if (errors != 0) $fatal(1, "alarm_fsm_testbench: %0d failure(s)", errors);
        $display("PASS alarm_fsm_testbench");
        $finish;
    end
endmodule
