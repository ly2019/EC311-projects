`timescale 1ns / 1ps

module display_tb_TM;
    reg clk = 0;
    reg [3:0] d7 = 7, d6 = 6, d5 = 5, d4 = 4;
    reg [3:0] d3 = 3, d2 = 2, d1 = 1, d0 = 0;
    wire [7:0] an;
    wire [6:0] seg;
    wire dp;

    display uut(.clk(clk), .d7(d7), .d6(d6), .d5(d5), .d4(d4),
        .d3(d3), .d2(d2), .d1(d1), .d0(d0), .an(an), .seg(seg), .dp(dp));

    always #5 clk = ~clk;

    initial begin
        // Digit lasts 131072 clocks = 1,310,720 ns.
        #10;                         // d0: an=11111110, seg=1000000, dp=1
        #1310720;                    // d1: an=11111101, seg=1111001, dp=1
        #1310720;                    // d2: an=11111011, seg=0100100, dp=0
        #1310720;                    // d3: an=11110111, seg=0110000, dp=1
        #1310720;                    // d4: an=11101111, seg=0011001, dp=1
        #1310720;                    // d5: an=11011111, seg=0010010, dp=1
        #1310720;                    // d6: an=10111111, seg=0000010, dp=0
        #1310720;                    // d7: an=01111111, seg=1111000, dp=1
        #1310720;                    // Wrap to d0: an=11111110, seg=1000000.
        d0 = 8; #10;                 // Same anode; seg=0000000 immediately.
        $finish;
    end
endmodule
