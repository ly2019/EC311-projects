`timescale 1ns / 1ps

module decoder_tb();

  	reg [3:0] number;
    wire [6:0] seg;

  	decoder dec(.number(number), .seg(seg));

    	initial
   		begin
                // Zero; expected seg=1000000
        number = 4'b0000;
          #1  $display("seg=%b,(0; expected seg=1000000)",seg);

        // Number 1; expected seg=1111001
        #10
        number = 4'b0001;
          #1  $display("seg=%b,(1; expected seg=1111001)",seg);

        // Number 2; expected seg=0100100
        #10
        number = 4'b0010;
          #1  $display("seg=%b,(2; expected seg=0100100)",seg);

        // Number 3; expected seg=0110000
        #10
        number = 4'b0011;
          #1  $display("seg=%b,(3; expected seg=0110000)",seg);

        // Number 4; expected seg=0011001
        #10
        number = 4'b0100;
          #1  $display("seg=%b,(4; expected seg=0011001)",seg);

        // Number 5; expected seg=0010010
        #10
        number = 4'b0101;
          #1  $display("seg=%b,(5; expected seg=0010010)",seg);

        // Number 6; expected seg=0000010
        #10
        number = 4'b0110;
          #1  $display("seg=%b,(6; expected seg=0000010)",seg);

        // Number 7; expected seg=1111000
        #10
        number = 4'b0111;
          #1  $display("seg=%b,(7; expected seg=1111000)",seg);

        // Number 8; expected seg=0000000
        #10
        number = 4'b1000;
          #1  $display("seg=%b,(8; expected seg=0000000)",seg);

        // Number 9; expected seg=0010000
        #10
        number = 4'b1001;
          #1  $display("seg=%b,(9; expected seg=0010000)",seg);
        $finish;
    	end
endmodule
