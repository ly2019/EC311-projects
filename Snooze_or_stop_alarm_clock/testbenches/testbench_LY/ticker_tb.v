`timescale 1ns / 1ps

module ticker_tb();
    localparam CLK_HZ = 10; //The clock frenquency
    localparam TICK_HZ= 1;           //The tick frequency
    reg  clk = 0;
  	wire tick;

    ticker #(.CLK_HZ(CLK_HZ),.TICK_HZ(TICK_HZ)) uut(.clk(clk), .tick(tick));
  
    always #1 clk = ~clk;

  
  	  // waveform dump
  //  initial begin
 //       $dumpfile("dump.vcd");                       // file name
  //     $dumpvars(0, ticker_tb);           
 //  end

    initial begin
      //check initial tick at clk=0
      $display("tick = %d, clk_count =%0d, (expect 1 0 )", tick, uut.clk_count); 
      
      //no update when clk_count is less than CLK_PER_TICK
      #4
      $display("tick = %d, clk_count =%d, (expect 0 2 )", tick, uut.clk_count); 

      #4
      $display("tick = %d, clk_count =%d, (expect 0 4 )", tick, uut.clk_count); 
      
      #11
      $display("tick = %d, clk_count =%d, (expect 0 9 )", tick, uut.clk_count);
      
      //tick=1 when clk_count after CLK_PER_TICK cycles, and clk_count becomes 0  
      #1
      $display("tick = %d, clk_count =%d, (expect 1 0 )", tick, uut.clk_count); 
      

    $finish;
    
    end
  
  
endmodule
