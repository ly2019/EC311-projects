`timescale 1ns / 1ps

module tb_carry_select_adder;
    reg [3:0] a, b;
    reg mode, c_in;
    wire [3:0] sum;
    wire cout;
    integer errors;

    carry_select_adder dut (
        .a(a), .b(b), .mode(mode), .c_in(c_in), .sum(sum), .cout(cout)
    );

    task check;
        input [3:0] av, bv;
        input subtract, cin_value;
        input [4:0] expected; // {carry-out, four-bit sum}
        begin
            a = av; b = bv; mode = subtract; c_in = cin_value;
            #10;
            if ({cout, sum} !== expected) begin
                errors = errors + 1;
                $display("FAIL adder: A=%h B=%h mode=%b cin=%b expected=%b got=%b",
                    a, b, mode, c_in, expected, {cout, sum});
            end
        end
    endtask

`ifdef DUMP_VCD
    initial begin
        $dumpfile("tb_carry_select_adder.vcd");
        $dumpvars(0, tb_carry_select_adder);
    end
`endif

    initial begin
        errors = 0;
        // Main cases: addition and subtraction.
        check(5, 3, 0, 0, 5'b01000); // 5+3 = 8
        check(5, 3, 1, 0, 5'b10010); // 5-3 = 2, no borrow
        // Edge cases: carry between halves, carry-out, borrow, and equality.
        check(3, 1, 0, 0, 5'b00100); // 3+1 = 4
        check(15, 0, 0, 1, 5'b10000); // 15+0+1 = 0, carry=1
        check(3, 5, 1, 1, 5'b01110); // 3-5 = E; subtraction ignores cin
        check(5, 5, 1, 0, 5'b10000); // 5-5 = 0, no borrow
        if (errors == 0) $display("PASS tb_carry_select_adder: 6 cases");
        else $display("FAIL tb_carry_select_adder: %0d errors", errors);
        $finish;
    end
endmodule
