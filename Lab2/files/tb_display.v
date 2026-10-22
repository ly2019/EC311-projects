
`timescale 1ns / 1ps

module display_tb();
	reg  clk = 0;    
  reg  [3:0] d3, d2, d1, d0;  // four 4-bit number
 	wire [3:0] an;
  	wire [6:0] seg;
       
    reg  rst;
    wire [3:0] count;

  	display display1(.clk(clk), .d0(d0), .d1(d1), .d2(d2), .d3(d3), .an(an), .seg(seg));
	
  	always #5 clk = ~clk;
  
    initial
    begin
    
    //manually set the four numbers to be 8,3,5,A
    d3 = 4'hA; d2 = 4'h5; d1 = 4'h3; d0 = 4'h8;
    
    //We are just testing the display of seg, and which an is on.
    //manually put int counter==0000 0000 0000 0000 0000
	display1.counter = 20'h00000; #10;
    $display("digit 0: an=%b seg=%b  (expect 1110 0000000 = 8)", an, seg);
      
	//manually put int counter==0100 0000 0000 0000 0000
    display1.counter = 20'h40000; #10;
    $display("digit 1: an=%b seg=%b  (expect 1101 0110000 = 3)", an, seg);
      
      
	//manually put int counter==1000 0000 0000 0000 0000
    display1.counter = 20'h80000; #10;
    $display("digit 2: an=%b seg=%b  (expect 1011 0010010 = 5)", an, seg);
      
	//manually put int counter==1100 0000 0000 0000 0000
    display1.counter = 20'hC0000; #10;
    $display("digit 3: an=%b seg=%b  (expect 0111 0001000 = A)", an, seg);
    
    //manually put int counter==0000 0000 1000 0000 0000
	display1.counter = 20'h00000; #10;
    $display("digit 0: an=%b seg=%b  (expect 1110 0000000 = 8)", an, seg);
      
	//manually put int counter==0100 0000 1000 0000 0000
    display1.counter = 20'h40000; #10;
    $display("digit 1: an=%b seg=%b  (expect 1101 0110000 = 3)", an, seg);
      
      
	//manually put int counter==1000 0000 1000 0000 0000
    display1.counter = 20'h80000; #10;
    $display("digit 2: an=%b seg=%b  (expect 1011 0010010 = 5)", an, seg);
      
	//manually put int counter==1100 0000 1000 0000 0000
    display1.counter = 20'hC0000; #10;
    $display("digit 3: an=%b seg=%b  (expect 0111 0001000 = A)", an, seg);

    $finish;
    end
endmodule