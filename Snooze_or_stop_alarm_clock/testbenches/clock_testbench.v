`timescale 1ns / 1ps

module clock_testbench();
    reg clk, reset, tick;
    wire [3:0] hour1, hour0, minute1, minute0;
    integer errors = 0;

    clock system_under_test(.clk(clk), .reset(reset), .tick(tick),
        .hour1(hour1), .hour0(hour0), .minute1(minute1), .minute0(minute0));

    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz; drive inputs between rising edges.

    task check_time;
        input integer h, m, s;
        reg [3:0] eh1, eh0, em1, em0;
        begin
            eh1 = h / 10; eh0 = h % 10;
            em1 = m / 10; em0 = m % 10;
            if ({hour1, hour0, minute1, minute0} !==
                {eh1, eh0, em1, em0} ||
                system_under_test.second !== s) begin
                $display("FAIL clock at %0t: expected %0d:%0d:%0d, got %0d%0d:%0d%0d:%0d",
                    $time, h, m, s, hour1, hour0, minute1, minute0,
                    system_under_test.second);
                errors = errors + 1;
            end
        end
    endtask

    // One simulated second per 10 ns while tick is high.
    task advance_seconds;
        input integer count;
        begin
            tick = 1;
            repeat (count) #10;
            tick = 0;
        end
    endtask

    initial begin
        reset = 1; tick = 0;
        #20;
        check_time(6, 58, 0);
        reset = 0;
        #20; // No tick: time must hold.
        check_time(6, 58, 0);

        advance_seconds(59);
        check_time(6, 58, 59);
        advance_seconds(1); // Seconds carry into minutes.
        check_time(6, 59, 0);
        advance_seconds(60); // Minutes carry into hours.
        check_time(7, 0, 0);
        advance_seconds(61199);
        check_time(23, 59, 59);
        advance_seconds(1); // Midnight wrap.
        check_time(0, 0, 0);

        advance_seconds(37);
        check_time(0, 0, 37);
        reset = 1; tick = 1;
        #10; // Reset should win over tick and restart at 06:58:00.
        // Known design defect: all_modules.v does not reset second.
        check_time(6, 58, 0);
        reset = 0; tick = 0;
        #10;
        if (errors != 0) $fatal(1, "clock_testbench: %0d failure(s)", errors);
        $display("PASS clock_testbench");
        $finish;
    end
endmodule
