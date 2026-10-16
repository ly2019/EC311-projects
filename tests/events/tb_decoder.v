`timescale 1ns / 1ps

module tb_decoder;
    reg [3:0] hex;
    wire [6:0] seg;
    integer errors;

    decoder dut (.hex(hex), .seg(seg));

    task check;
        input [3:0] digit;
        input [6:0] expected;
        begin
            hex = digit;
            #10;
            if (seg !== expected) begin
                errors = errors + 1;
                $display("FAIL decoder: hex=%h expected=%b got=%b", hex, expected, seg);
            end
        end
    endtask

`ifdef DUMP_VCD
    initial begin
        $dumpfile("tb_decoder.vcd");
        $dumpvars(0, tb_decoder);
    end
`endif

    initial begin
        errors = 0;
        // Main cases: a number and a hexadecimal letter.
        check(4'h1, 7'b1111001);
        check(4'hA, 7'b0001000);
        // Edges: zero, all segments lit, highest value, and default blank.
        check(4'h0, 7'b1000000);
        check(4'h8, 7'b0000000);
        check(4'hF, 7'b0001110);
        check(4'bxxxx, 7'b1111111);
        if (errors == 0) $display("PASS tb_decoder: 6 cases");
        else $display("FAIL tb_decoder: %0d errors", errors);
        $finish;
    end
endmodule
