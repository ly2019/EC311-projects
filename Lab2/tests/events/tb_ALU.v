`timescale 1ns / 1ps

module tb_ALU;
    reg [3:0] a, b, opt;
    reg c_in;
    wire [3:0] out;
    wire cout;
    integer errors;

    ALU dut (.a(a), .b(b), .opt(opt), .c_in(c_in), .out(out), .cout(cout));

    task check;
        input [3:0] opcode, av, bv;
        input cin_value;
        input [3:0] expected_out;
        input expected_cout;
        begin
            opt = opcode; a = av; b = bv; c_in = cin_value;
            #10;
            if ({cout, out} !== {expected_cout, expected_out}) begin
                errors = errors + 1;
                $display("FAIL ALU: op=%h A=%h B=%h cin=%b expected=%b_%h got=%b_%h",
                    opt, a, b, c_in, expected_cout, expected_out, cout, out);
            end
        end
    endtask

`ifdef DUMP_VCD
    initial begin
        $dumpfile("tb_ALU.vcd");
        $dumpvars(0, tb_ALU);
    end
`endif

    initial begin
        errors = 0;
        // One representative case per operation.
        // Arguments: opcode, A, B, cin, expected result, expected carry.
        check(4'h0, 3, 9, 0, 4'h1, 0); // AND
        check(4'h1, 3, 9, 0, 4'hB, 0); // OR
        check(4'h2, 3, 9, 0, 4'hE, 0); // NAND
        check(4'h3, 3, 9, 0, 4'h4, 0); // NOR
        check(4'h4, 3, 9, 0, 4'hA, 0); // XOR
        check(4'h5, 3, 9, 0, 4'h5, 0); // XNOR
        check(4'h6, 3, 9, 0, 4'hC, 0); // NOT A
        check(4'h7, 3, 9, 0, 4'h6, 0); // NOT B
        check(4'h8, 3, 9, 0, 4'hD, 0); // Negate A
        check(4'h9, 3, 9, 0, 4'h7, 0); // Negate B
        check(4'hA, 5, 3, 0, 4'h8, 0); // A+B
        check(4'hB, 5, 3, 0, 4'h2, 1); // A-B
        check(4'hC, 7, 3, 0, 4'h5, 0); // A*B: keep low four bits of 21
        check(4'hD, 5, 3, 0, 4'hE, 0); // B-A
        check(4'hE, 5, 0, 0, 4'h6, 0); // A+1
        check(4'hF, 5, 0, 0, 4'h4, 1); // A-1

        // A few edge cases, including the fixed increment bug.
        check(4'hA, 15, 0, 1, 4'h0, 1); // Addition carry-out
        check(4'hB, 3, 5, 1, 4'hE, 0);  // Borrow; cin is ignored
        check(4'hE, 5, 0, 1, 4'h6, 0);  // Still 5+1, not 5+2
        check(4'hE, 15, 0, 1, 4'h0, 1); // Increment wraparound
        check(4'hF, 0, 0, 0, 4'hF, 0);  // Decrement below zero

        if (errors == 0) $display("PASS tb_ALU: 21 cases");
        else $display("FAIL tb_ALU: %0d errors", errors);
        $finish;
    end
endmodule
