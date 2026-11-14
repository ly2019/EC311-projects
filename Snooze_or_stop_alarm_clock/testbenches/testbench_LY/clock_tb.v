`timescale 1ns / 1ps

module clock_tb();
    reg  clk = 0, tick = 0, reset=0;

  	wire [3:0] hour1, hour0, minute1, minute0;

  clock uut(.clk(clk), .tick(tick), .reset(reset), .hour1(hour1), .hour0(hour0), .minute1(minute1), .minute0(minute0));
  
    always #5 clk = ~clk;

  
  	  // waveform dump
  //  initial begin
 //       $dumpfile("dump.vcd");                       // file name
 //     $dumpvars(0, clock_tb);           
 //  end

    initial begin
      //1. check inital time

      $display("%d, %d, %d, %d, %d (expect 0,6,5,8,0 )", hour1, hour0, minute1, minute0, uut.second); 
      
      //2. check time after 11 seconds
      repeat (11) begin
			@(posedge clk); #1 tick = 1;  // wait a tiny delay after the edge
      end
      $display("%d, %d, %d, %d, %d (expect 0,6,5,8,10 )", hour1, hour0, minute1, minute0, uut.second); 
      
      //3. check time after 51 seconds
      repeat (50) begin
			@(posedge clk); #1 tick = 1;  // wait a tiny delay after the edge
      end
      $display("%d, %d, %d, %d, %d (expect 0,6,5,9,0 )", hour1, hour0, minute1, minute0, uut.second); 
      
      //4. check time after 60 seconds
      repeat (60) begin
			@(posedge clk); #1 tick = 1;  // wait a tiny delay after the edge
      end
      $display("%d, %d, %d, %d, %d (expect 0,7,0,0,0 )", hour1, hour0, minute1, minute0, uut.second); 
      
      //5. check time after 61200 seconds (17 hours)
      repeat (61200) begin
			@(posedge clk); #1 tick = 1;  // wait a tiny delay after the edge
      end
      $display("%d, %d, %d, %d, %d (expect 0,0,0,0,0 )", hour1, hour0, minute1, minute0, uut.second); 

    $finish;
    
    end
  
  
endmodule
