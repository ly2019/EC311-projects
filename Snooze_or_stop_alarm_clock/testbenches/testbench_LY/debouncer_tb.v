`timescale 1ns / 1ps

module debouncer_tb();
    reg  clk = 0, reset=0, button=0;

  	wire [3:0] debounced_button ;
 
  debouncer uut(.clk(clk),.rst(reset),.button(button),.debounced_button(dbutton));
  
    always #5 clk = ~clk;

  
    initial begin
      reset = 1;
      //1. check inital value, expect 0, 0
      #10
      $display("%d, %d, %d (expect 0 0 0 )", uut.counter, button, dbutton); 
      
      //2. dbutton continue to be 0 when nothing changes if button not 1
      #10
      $display("%d, %d, %d (expect 0 0 0 )", uut.counter, button, dbutton); 
      
      //3. dbutton continue to be 0 when nothing changes if button is 1 for a short period
      reset = 1;
      #10
      reset = 0;
      button = 1;
      #10
      $display("%d, %d, %d (expect 1 1 0 )", uut.counter, button, dbutton); 
      #999990
      $display("%d, %d, %d (expect 100000 1 0 )", uut.counter, button, dbutton); 
      //4. dbutton becomes 1 when button is on for 1,000,000 clk cycles in total
      //after 10*1000000 ns
      reset = 1;
      #10
      reset = 0;
      button = 1;
      #9999990
      $display("%d, %d, %d (expect 999999 1 0 )", uut.counter, button, dbutton); 
      #10
      $display("%d, %d, %d (expect 1000000 1 1 )", uut.counter, button, dbutton); 
      #10
      $display("%d, %d, %d (expect 1000001 1 1 )", uut.counter, button, dbutton); 
      button = 0;
      $display("%d, %d, %d (expect 1000001 0 1 )", uut.counter, button, dbutton); 
      #10
      $display("%d, %d, %d (expect 0 0 0)", uut.counter, button, dbutton); 

	

    $finish;
    
    end
  
  
endmodule
