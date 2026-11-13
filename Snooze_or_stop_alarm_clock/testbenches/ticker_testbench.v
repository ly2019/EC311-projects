`timescale 1ns / 1ps

module ticker_testbench();
    reg clk;
    wire tick, every_cycle_tick;
    integer errors = 0;
    integer cycle;

    // Use the existing parameters to make one tick every four clock cycles.
    ticker #(.CLK_HZ(100), .TICK_HZ(25)) system_under_test(
        .clk(clk), .tick(tick));
    ticker #(.CLK_HZ(1), .TICK_HZ(1)) divide_by_one(
        .clk(clk), .tick(every_cycle_tick));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        #1; // Counter initializes to zero, so tick starts high.
        if (tick !== 1'b1 || every_cycle_tick !== 1'b1) begin
            $display("FAIL ticker initial tick"); errors = errors + 1;
        end
        #9;
        // Sample after each rising edge: low, low, low, high, repeating.
        for (cycle = 1; cycle <= 20; cycle = cycle + 1) begin
            if (tick !== ((cycle % 4) == 0) || every_cycle_tick !== 1'b1) begin
                $display("FAIL ticker at %0t, cycle %0d", $time, cycle);
                errors = errors + 1;
            end
            #10;
        end
        if (errors != 0) $fatal(1, "ticker_testbench: %0d failure(s)", errors);
        $display("PASS ticker_testbench");
        $finish;
    end
endmodule
