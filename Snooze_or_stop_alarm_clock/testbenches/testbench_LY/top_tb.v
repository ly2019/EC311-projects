`timescale 1ns / 1ps

module top_tb();
    reg  clk = 0;
  	reg [3:0] button ;
    wire      led;        // LED for buzz
    wire [6:0] seg;         // segment pins {g,f,e,d,c,b,a}
    wire [7:0] an;          // digit-enable pins
    wire     dp;  
  
 
  	top top(.clk(clk),.led(led),.button(button),.seg(seg),.an(an),.dp(dp));
  
    always #5 clk = ~clk;
  
    initial begin
      button = 4'b0000;
      button[3] = 1;
      //1. check inital value, expect 0, 0
      #10
      $display("%d, %d, %d, %d (expect 0 6 5 8 )", top.hour1, top.hour0, top.minute1, top.minute0); 
      
      //2. Trigger
      button = 4'b0000;
      button[3] = 1;
      #10
      button[3] = 0;
      button[2] = 1;

      $display("trigger=%d, buzz=%d led=%d (expect 0 0 0)",top.trigger, top.buzz, led );
      //wait for 9_999_999 ns
      #9_999_999
      $display("trigger=%d, buzz=%d led=%d (expect 0 0 0)",top.trigger, top.buzz, led ); 
      //wait a bit more
      #10
      $display("trigger=%d, buzz=%d led=%d (expect 1 0 0)",top.trigger, top.buzz, led ); 
      #10
      $display("trigger=%d, buzz=%d led=%d (expect 1 1 1)",top.trigger, top.buzz, led );  
      
      //3. Trigger and stop
      button = 4'b0000;
      button[3] = 1;
      #10
      button[3] = 0;
      button[2] = 1;
      #11_000_000
      $display("trigger=%d, buzz=%d led=%d (expect 1 1 1)",top.trigger, top.buzz, led );
      button[2] = 0;
      #10
      $display("trigger=%d, buzz=%d led=%d (expect 0 1 1)",top.trigger, top.buzz, led );
      button[1] = 1;
      #11_000_000
      $display("trigger=%d, buzz=%d led=%d (expect 0 0 0)",top.trigger, top.buzz, led );
      
      //4. Trigger and snooze
      button = 4'b0000;
      button[3] = 1;
      #10
      button[3] = 0;
      button[2] = 1;
      #11_000_000
      button[2] = 0;
      #10
      $display("trigger=%d, buzz=%d led=%d (expect 0 1 1)",top.trigger, top.buzz, led );
      button[0] = 1;
      #100_000_002
      $display("snooze_cnt=%d, timer_en=%d, led=%d (expect 1 1 0)",top.snooze_cnt, top.timer_en, led );
      //transition into snooze waiting
      #10
      $display("snooze_cnt=%d, timer_en=%d, led=%d (expect 1 0 0)",top.snooze_cnt, top.timer_en, led );
      $display("m1=%d, m0=%d,  s1=%d, s0 (expect 0 5 0 0)", top.m1, top.m0, top.s1, top.s0 );
      //reduce 1s after 1000_000_000 cycles
      #1000_000_000
      $display("m1=%d, m0=%d,  s1=%d, s0=%d (expect 0 4 5 9)", top.m1, top.m0, top.s1, top.s0 );
    $finish;
    
    end
  
      initial begin
      //5.force timeout and see whether it buzz again
      
      force top.timeout=1;
      #10
      release top.timeout;
      $display("buzz=%d, led=%d (expect 1 1)",top.buzz, led );
      #10
      $display("buzz=%d, led=%d (expect 1 1)",top.buzz, led );

     $finish;
    
    	end
//
  
  
endmodule

  
    initial begin
      button = 4'b0000;
      button[3] = 1;
      //1. check inital value, expect 0, 0
      #10
      $display("%d, %d, %d, %d (expect 0 6 5 8 )", top.hour1, top.hour0, top.minute1, top.minute0); 
      
      //2. Trigger
      button = 4'b0000;
      button[3] = 1;
      #10
      button[3] = 0;
      button[2] = 1;

      $display("trigger=%d, buzz=%d led=%d (expect 0 0 0)",top.trigger, top.buzz, led );
      //wait for 9_999_999 ns
      #9_999_999
      $display("trigger=%d, buzz=%d led=%d (expect 0 0 0)",top.trigger, top.buzz, led ); 
      //wait a bit more
      #10
      $display("trigger=%d, buzz=%d led=%d (expect 1 0 0)",top.trigger, top.buzz, led ); 
      #10
      $display("trigger=%d, buzz=%d led=%d (expect 1 1 1)",top.trigger, top.buzz, led );  
      
      //3. Trigger and stop
      button = 4'b0000;
      button[3] = 1;
      #10
      button[3] = 0;
      button[2] = 1;
      #11_000_000
      $display("trigger=%d, buzz=%d led=%d (expect 1 1 1)",top.trigger, top.buzz, led );
      button[2] = 0;
      #10
      $display("trigger=%d, buzz=%d led=%d (expect 0 1 1)",top.trigger, top.buzz, led );
      button[1] = 1;
      #11_000_000
      $display("trigger=%d, buzz=%d led=%d (expect 0 0 0)",top.trigger, top.buzz, led );
      
      //4. Trigger and snooze
      button = 4'b0000;
      button[3] = 1;
      #10
      button[3] = 0;
      button[2] = 1;
      #11_000_000
      button[2] = 0;
      #10
      $display("trigger=%d, buzz=%d led=%d (expect 0 1 1)",top.trigger, top.buzz, led );
      button[0] = 1;
      #100_000_002
      $display("snooze_cnt=%d, timer_en=%d, led=%d (expect 1 1 0)",top.snooze_cnt, top.timer_en, led );
      //transition into snooze waiting
      #10
      $display("snooze_cnt=%d, timer_en=%d, led=%d (expect 1 0 0)",top.snooze_cnt, top.timer_en, led );
      $display("m1=%d, m0=%d,  s1=%d, s0 (expect 0 5 0 0)", top.m1, top.m0, top.s1, top.s0 );
      //reduce 1s after 1000_000_000 cycles
      #1000_000_000
      $display("m1=%d, m0=%d,  s1=%d, s0=%d (expect 0 4 5 9)", top.m1, top.m0, top.s1, top.s0 );
    $finish;
    
    end
  
//  //5.force timeout and see whether it buzzes again
	initial begin
    button = 4'b0000;
    #100;                                        // let the design settle

    // put FSM in SNOOZE_1_WAITING
    top.fsm.state = top.fsm.SNOOZE_1_WAITING;
    #10
    $display("state=%b (expect 00001000)", top.fsm.state);


    force top.snooze_cnt = 1;
    force top.timeout = 1;
    $display("state=%b buzz=%b led=%b timout=%b (expect 00001000 0 0 1)", top.fsm.state, top.buzz, led, top.timeout);
    #10;
    release top.snooze_cnt;
    release top.timeout;

    $display("state=%b buzz=%b led=%b timout=%b (expect 00010000 1 1 0)", top.fsm.state, top.buzz, led, top.timeout);

    $finish;
      
	end
  
  
