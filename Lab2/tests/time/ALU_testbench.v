`timescale 1ns / 1ps

module ALU_testbench();

    reg [3:0] a, b, opt;
    reg c_in;
    wire c_out;
    wire [3:0] result;

    ALU alu(.a(a), .b(b), .opt(opt), .c_in(c_in),
            .cout(c_out), .out(result));

    initial
    begin
        // Initial inputs; expected result=0, c_out=0
        a = 4'b0000;
        b = 4'b0000;
        c_in = 0;
        opt = 4'b0000;

        // AND; expected result=1, c_out=0
        #10
        a = 4'b0011;
        b = 4'b1001;
        c_in = 0;
        opt = 4'b0000;

        // OR; expected result=B, c_out=0
        #10
        a = 4'b0011;
        b = 4'b1001;
        c_in = 0;
        opt = 4'b0001;

        // NAND; expected result=E, c_out=0
        #10
        a = 4'b0011;
        b = 4'b1001;
        c_in = 0;
        opt = 4'b0010;

        // NOR; expected result=4, c_out=0
        #10
        a = 4'b0011;
        b = 4'b1001;
        c_in = 0;
        opt = 4'b0011;

        // XOR; expected result=A, c_out=0
        #10
        a = 4'b0011;
        b = 4'b1001;
        c_in = 0;
        opt = 4'b0100;

        // XNOR; expected result=5, c_out=0
        #10
        a = 4'b0011;
        b = 4'b1001;
        c_in = 0;
        opt = 4'b0101;

        // NOT A; expected result=C, c_out=0
        #10
        a = 4'b0011;
        b = 4'b1001;
        c_in = 0;
        opt = 4'b0110;

        // NOT B; expected result=6, c_out=0
        #10
        a = 4'b0011;
        b = 4'b1001;
        c_in = 0;
        opt = 4'b0111;

        // Negate A; expected result=D, c_out=0
        #10
        a = 4'b0011;
        b = 4'b1001;
        c_in = 0;
        opt = 4'b1000;

        // Negate B; expected result=7, c_out=0
        #10
        a = 4'b0011;
        b = 4'b1001;
        c_in = 0;
        opt = 4'b1001;

        // Addition; expected result=8, c_out=0
        #10
        a = 4'b0101;
        b = 4'b0011;
        c_in = 0;
        opt = 4'b1010;

        // Subtraction A-B; expected result=2, c_out=1
        #10
        a = 4'b0101;
        b = 4'b0011;
        c_in = 0;
        opt = 4'b1011;

        // Multiplication: keep the low four bits of 21; expected result=5, c_out=0
        #10
        a = 4'b0111;
        b = 4'b0011;
        c_in = 0;
        opt = 4'b1100;

        // Subtraction B-A; expected result=E, c_out=0
        #10
        a = 4'b0101;
        b = 4'b0011;
        c_in = 0;
        opt = 4'b1101;

        // Increment A; expected result=6, c_out=0
        #10
        a = 4'b0101;
        b = 4'b0000;
        c_in = 0;
        opt = 4'b1110;

        // Decrement A; expected result=4, c_out=1
        #10
        a = 4'b0101;
        b = 4'b0000;
        c_in = 0;
        opt = 4'b1111;

        // Addition overflow with carry-in; expected result=0, c_out=1
        #10
        a = 4'b1111;
        b = 4'b0000;
        c_in = 1;
        opt = 4'b1010;

        // Subtraction with borrow: carry-in is ignored; expected result=E, c_out=0
        #10
        a = 4'b0011;
        b = 4'b0101;
        c_in = 1;
        opt = 4'b1011;

        // Fixed bug: increment must ignore carry-in; expected result=6, c_out=0
        #10
        a = 4'b0101;
        b = 4'b0000;
        c_in = 1;
        opt = 4'b1110;

        // Increment wraparound; expected result=0, c_out=1
        #10
        a = 4'b1111;
        b = 4'b0000;
        c_in = 1;
        opt = 4'b1110;

        // Decrement zero; expected result=F, c_out=0
        #10
        a = 4'b0000;
        b = 4'b0000;
        c_in = 0;
        opt = 4'b1111;

        #10 
        $finish;
    end
endmodule
