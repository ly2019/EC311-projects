`timescale 1ns / 1ps

module display_testbench();
    reg clk;
    reg [3:0] d7, d6, d5, d4, d3, d2, d1, d0;
    wire [7:0] an;
    wire [6:0] seg;
    wire dp;
    integer errors = 0;

    display system_under_test(.clk(clk), .d7(d7), .d6(d6), .d5(d5), .d4(d4),
        .d3(d3), .d2(d2), .d1(d1), .d0(d0), .an(an), .seg(seg), .dp(dp));

    initial clk = 0;
    always #5 clk = ~clk;

    task check_digit;
        input [7:0] expected_an;
        input [6:0] expected_seg;
        input expected_dp;
        begin
            if ({an,seg,dp} !== {expected_an,expected_seg,expected_dp}) begin
                $display("FAIL display at %0t: expected an=%b seg=%b dp=%b; got %b %b %b",
                    $time, expected_an, expected_seg, expected_dp, an, seg, dp);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        d7 = 7; d6 = 6; d5 = 5; d4 = 4;
        d3 = 3; d2 = 2; d1 = 1; d0 = 0;
        #10;
        check_digit(8'b11111110, 7'b1000000, 1);
        #1310700; // Just before the first scan transition.
        check_digit(8'b11111110, 7'b1000000, 1);
        #10; // 2^17 clocks per digit = 1,310,720 ns.
        check_digit(8'b11111101, 7'b1111001, 1);
        #1310720;
        check_digit(8'b11111011, 7'b0100100, 0);
        #1310720;
        check_digit(8'b11110111, 7'b0110000, 1);
        #1310720;
        check_digit(8'b11101111, 7'b0011001, 1);
        #1310720;
        check_digit(8'b11011111, 7'b0010010, 1);
        #1310720;
        check_digit(8'b10111111, 7'b0000010, 0);
        #1310720;
        check_digit(8'b01111111, 7'b1111000, 1);
        #1310720; // Counter wraps: scan returns to the rightmost digit.
        check_digit(8'b11111110, 7'b1000000, 1);
        d0 = 9;
        #10;
        check_digit(8'b11111110, 7'b0010000, 1);

        if (errors != 0) $fatal(1, "display_testbench: %0d failure(s)", errors);
        $display("PASS display_testbench");
        $finish;
    end
endmodule
