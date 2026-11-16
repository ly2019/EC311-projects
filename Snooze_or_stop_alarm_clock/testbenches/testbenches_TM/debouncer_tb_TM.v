`timescale 1ns / 1ps

module debouncer_tb_TM;
    reg clk = 0, rst = 1, button = 0;
    wire debounced_button;

    debouncer uut(.clk(clk), .rst(rst), .button(button),
        .debounced_button(debounced_button));

    always #5 clk = ~clk;

    initial begin
        #20;                         // Reset: output=0, counter=0.

        rst = 0;
        button = 1; #100;            // Short press rejected: output=0.
        button = 0; #20;             // Release clears the counter.
        button = 1; #10000000;       // 1,000,000 clocks: output still 0.

        #10;                         // Next clock: output=1.

        #20;                         // Held button: output stays 1.

        button = 0; #10;             // Release: output=0, counter=0.
        button = 1; #10000010;       // Another valid press: output=1.
        rst = 1; #10;                // Reset overrides held button: output=0.
        
        $finish;
    end
endmodule
