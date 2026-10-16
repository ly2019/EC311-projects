`timescale 1ns / 1ps

module top_testbench();

    reg clk;
    reg [12:0] sw;
    wire led, dp;
    wire [6:0] seg;
    wire [3:0] an;

    top system_under_test(.clk(clk), .sw(sw), .led(led),
                          .seg(seg), .an(an), .dp(dp));

    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz test clock

    // Hold each instruction for 11 ms so all four digits are scanned.
    // Switch order: {opcode[3:0], A[3:0], B[3:0], carry-in}.
    // dp should stay 1 (decimal point off) throughout.
    initial
    begin
        // Addition example: 5+3=8
        // Expected display: A538; led=0
        sw = {4'b1010, 4'b0101, 4'b0011, 1'b0};

        // AND example: 3 AND 9=1
        // Expected display: 0391; led=0
        #11000000
        sw = {4'b0000, 4'b0011, 4'b1001, 1'b0};

        // Carry-out: 15+0+1 wraps to zero
        // Expected display: AF00; led=1
        #11000000
        sw = {4'b1010, 4'b1111, 4'b0000, 1'b1};

        // Borrow: 3-5 gives four-bit E
        // Expected display: B35E; led=0
        #11000000
        sw = {4'b1011, 4'b0011, 4'b0101, 1'b0};

        // Fixed increment bug: 5+1 stays 6 with carry-in set
        // Expected display: E506; led=0
        #11000000
        sw = {4'b1110, 4'b0101, 4'b0000, 1'b1};

        #11000000 
        $finish;
    end
endmodule
