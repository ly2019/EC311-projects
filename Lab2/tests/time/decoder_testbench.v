`timescale 1ns / 1ps

module decoder_testbench();

    reg [3:0] hex;
    wire [6:0] seg;

    decoder dec(.hex(hex), .seg(seg));

    initial
    begin
        // Zero; expected seg=1000000
        hex = 4'b0000;

        // Number 1; expected seg=1111001
        #10
        hex = 4'b0001;

        // Hexadecimal A; expected seg=0001000
        #10
        hex = 4'b1010;

        // Number 8: all seven segments on; expected seg=0000000
        #10
        hex = 4'b1000;

        // Hexadecimal F; expected seg=0001110
        #10
        hex = 4'b1111;

        // Unknown input: default blanks all segments; expected seg=1111111
        #10
        hex = 4'bxxxx;

        #10
        $finish;
    end
endmodule
