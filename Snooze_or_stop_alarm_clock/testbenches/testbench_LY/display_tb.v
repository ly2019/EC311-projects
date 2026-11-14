`timescale 1ns / 1ps

module display_tb();
    reg  clk = 0;
    reg  [3:0] d7, d6, d5, d4, d3, d2, d1, d0;   // eight 4-bit digits
    wire [7:0] an;
    wire [6:0] seg;

    display display1(.clk(clk),
                     .d0(d0), .d1(d1), .d2(d2), .d3(d3),
                     .d4(d4), .d5(d5), .d6(d6), .d7(d7),
                     .an(an), .seg(seg));

    always #5 clk = ~clk;

    initial
    begin
    d7 = 4'd7; d6 = 4'd6; d5 = 4'd5; d4 = 4'd4;
    d3 = 4'd3; d2 = 4'd2; d1 = 4'd1; d0 = 4'd0;

    // Only testing which anode is on (active low)
    // Second line of each pair: same top bits, different lower bits -> an should not change

    // counter[19:17] = 000 -> digit 0
    display1.counter = 20'h00000; #10;
    $display("counter=%h  an=%b  (expect 11111110, digit 0 on)", display1.counter, an);
    display1.counter = 20'h00800; #10;
    $display("counter=%h  an=%b  (expect 11111110, digit 0 on)", display1.counter, an);

    // counter[19:17] = 001 -> digit 1
    display1.counter = 20'h20000; #10;
    $display("counter=%h  an=%b  (expect 11111101, digit 1 on)", display1.counter, an);
    display1.counter = 20'h20800; #10;
    $display("counter=%h  an=%b  (expect 11111101, digit 1 on)", display1.counter, an);

    // counter[19:17] = 010 -> digit 2
    display1.counter = 20'h40000; #10;
    $display("counter=%h  an=%b  (expect 11111011, digit 2 on)", display1.counter, an);
    display1.counter = 20'h40800; #10;
    $display("counter=%h  an=%b  (expect 11111011, digit 2 on)", display1.counter, an);

    // counter[19:17] = 011 -> digit 3
    display1.counter = 20'h60000; #10;
    $display("counter=%h  an=%b  (expect 11110111, digit 3 on)", display1.counter, an);
    display1.counter = 20'h60800; #10;
    $display("counter=%h  an=%b  (expect 11110111, digit 3 on)", display1.counter, an);

    // counter[19:17] = 100 -> digit 4
    display1.counter = 20'h80000; #10;
    $display("counter=%h  an=%b  (expect 11101111, digit 4 on)", display1.counter, an);
    display1.counter = 20'h80800; #10;
    $display("counter=%h  an=%b  (expect 11101111, digit 4 on)", display1.counter, an);

    // counter[19:17] = 101 -> digit 5
    display1.counter = 20'hA0000; #10;
    $display("counter=%h  an=%b  (expect 11011111, digit 5 on)", display1.counter, an);
    display1.counter = 20'hA0800; #10;
    $display("counter=%h  an=%b  (expect 11011111, digit 5 on)", display1.counter, an);

    // counter[19:17] = 110 -> digit 6
    display1.counter = 20'hC0000; #10;
    $display("counter=%h  an=%b  (expect 10111111, digit 6 on)", display1.counter, an);
    display1.counter = 20'hC0800; #10;
    $display("counter=%h  an=%b  (expect 10111111, digit 6 on)", display1.counter, an);

    // counter[19:17] = 111 -> digit 7
    display1.counter = 20'hE0000; #10;
    $display("counter=%h  an=%b  (expect 01111111, digit 7 on)", display1.counter, an);
    display1.counter = 20'hE0800; #10;
    $display("counter=%h  an=%b  (expect 01111111, digit 7 on)", display1.counter, an);

    $finish;
    end
endmodule
