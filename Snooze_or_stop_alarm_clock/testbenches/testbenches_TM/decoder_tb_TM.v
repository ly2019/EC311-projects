`timescale 1ns / 1ps

module decoder_tb_TM;
    reg [3:0] number;
    wire [6:0] seg;

    decoder uut(.number(number), .seg(seg));

    initial begin
        // Active-low segments: {g,f,e,d,c,b,a}.
        number = 0; #10;             // seg=1000000
        number = 1; #10;             // seg=1111001
        number = 2; #10;             // seg=0100100
        number = 3; #10;             // seg=0110000
        number = 4; #10;             // seg=0011001
        number = 5; #10;             // seg=0010010
        number = 6; #10;             // seg=0000010
        number = 7; #10;             // seg=1111000
        number = 8; #10;             // seg=0000000 (all on)
        number = 9; #10;             // seg=0010000
        number = 10; #10;            // seg=1111111 (invalid digit: all off)
        $finish;
    end
endmodule
