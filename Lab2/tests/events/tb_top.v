`timescale 1ns / 1ps

module tb_top;
    reg clk = 0;
    reg [12:0] sw;
    wire led, dp;
    wire [6:0] seg;
    wire [3:0] an;
    integer errors;

    top dut (.clk(clk), .sw(sw), .led(led), .seg(seg), .an(an), .dp(dp));
    always #5 clk = ~clk;

    // Expected active-low segment patterns, {g,f,e,d,c,b,a}.
    function [6:0] glyph;
        input [3:0] digit;
        begin
            case (digit)
                4'h0: glyph = 7'b1000000;
                4'h1: glyph = 7'b1111001;
                4'h2: glyph = 7'b0100100;
                4'h3: glyph = 7'b0110000;
                4'h4: glyph = 7'b0011001;
                4'h5: glyph = 7'b0010010;
                4'h6: glyph = 7'b0000010;
                4'h7: glyph = 7'b1111000;
                4'h8: glyph = 7'b0000000;
                4'h9: glyph = 7'b0010000;
                4'hA: glyph = 7'b0001000;
                4'hB: glyph = 7'b0000011;
                4'hC: glyph = 7'b1000110;
                4'hD: glyph = 7'b0100001;
                4'hE: glyph = 7'b0000110;
                4'hF: glyph = 7'b0001110;
                default: glyph = 7'b1111111;
            endcase
        end
    endfunction

    task check;
        input [11:0] instruction; // {opcode, A, B}
        input cin_value;
        input [15:0] expected_display; // Left to right: opcode, A, B, result
        input expected_led;
        integer digit;
        reg [3:0] expected_an;
        begin
            @(negedge clk);
            sw = {instruction, cin_value};
            // Check each position as the real counter scans the display.
            for (digit = 0; digit < 4; digit = digit + 1) begin
                expected_an = ~(4'b0001 << digit);
                wait (an === expected_an);
                #1;
                if (seg !== glyph(expected_display[digit*4 +: 4]) ||
                    led !== expected_led || dp !== 1'b1) begin
                    errors = errors + 1;
                    $display("FAIL top: instruction=%h cin=%b digit=%0d seg=%b led=%b dp=%b",
                        instruction, cin_value, digit, seg, led, dp);
                end
            end
        end
    endtask

`ifdef DUMP_VCD
    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, sw, led, seg, an, dp);
    end
`endif

    initial begin
        sw = 0; errors = 0;
        // The lab's two main examples.
        check(12'hA53, 0, 16'hA538, 0); // 5+3 = 8
        check(12'h039, 0, 16'h0391, 0); // 3 AND 9 = 1
        // Edge cases: carry-out, borrow, and the increment regression.
        check(12'hAF0, 1, 16'hAF00, 1); // 15+0+1 wraps to zero
        check(12'hB35, 0, 16'hB35E, 0); // 3-5 = E, borrow
        check(12'hE50, 1, 16'hE506, 0); // 5+1 stays 6 with cin=1
        if (errors == 0) $display("PASS tb_top: 5 instructions / 20 digit samples");
        else $display("FAIL tb_top: %0d errors", errors);
        $finish;
    end

    // A stuck digit selector must fail rather than wait forever.
    initial begin
        #60000000;
        $display("FAIL tb_top: timeout waiting for display scanning");
        $finish;
    end
endmodule
