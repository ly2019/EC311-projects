`timescale 1ns / 1ps

module carry_select_adder_testbench();

    reg [3:0] a, b;
    reg mode, c_in;
    wire [3:0] sum;
    wire c_out;

    carry_select_adder adder(.a(a), .b(b), .mode(mode), .c_in(c_in),
                             .sum(sum), .cout(c_out));

    initial
    begin
        // Initial inputs; expected sum=0, c_out=0
        a = 4'b0000;
        b = 4'b0000;
        c_in = 0;
        mode = 0;

        // Addition; expected sum=8, c_out=0
        #10
        a = 4'b0101;
        b = 4'b0011;
        c_in = 0;
        mode = 0;

        // Subtraction; expected sum=2, c_out=1
        #10
        a = 4'b0101;
        b = 4'b0011;
        c_in = 0;
        mode = 1;

        // Carry from the lower two bits into the upper two bits; expected sum=4, c_out=0
        #10
        a = 4'b0011;
        b = 4'b0001;
        c_in = 0;
        mode = 0;

        // Addition overflow with carry-in; expected sum=0, c_out=1
        #10
        a = 4'b1111;
        b = 4'b0000;
        c_in = 1;
        mode = 0;

        // Subtraction with borrow: carry-in is ignored; expected sum=E, c_out=0
        #10
        a = 4'b0011;
        b = 4'b0101;
        c_in = 1;
        mode = 1;

        // Subtraction with equal numbers; expected sum=0, c_out=1
        #10
        a = 4'b0101;
        b = 4'b0101;
        c_in = 0;
        mode = 1;

        #10 
        $finish;
    end
endmodule
