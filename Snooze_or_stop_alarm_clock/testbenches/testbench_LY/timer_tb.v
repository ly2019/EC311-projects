`timescale 1ns / 1ps

module timer_tb();
    reg  clk = 0, tick = 0, timer_en=0;
    reg [1:0] snooze_cnt;
  	
    wire timeout;
  	wire [3:0] m1, m0,s1, s0;

    timer uut(.clk(clk), .tick(tick), .snooze_cnt(snooze_cnt), .timer_en(timer_en), .timeout(timeout),.m1(m1),.m0(m0),.s1(s1),.s0(s0));
  
    always #5 clk = ~clk;

  
  	  // waveform dump
    //initial begin
      //  $dumpfile("dump.vcd");                       // file name
     // $dumpvars(0, timer_tb);           // 0 = all levels, including inside the FSM
  // end

    initial begin
      //1. check snooze time
      {snooze_cnt} =2'b01; #10  //first snooze time is 300
      $display("snooze_time= %d (expect 300)", uut.snooze_time);     
      {snooze_cnt} =2'b10; #10  //second snooze time is 180
      $display("snooze_time= %d (expect 180)", uut.snooze_time); 

      //2. check time remain loading function
      //2.1 when timer_en is off, no loading
      {timer_en, snooze_cnt} =3'b001; #10
      $display("time_remain= %d (expect 0)", uut.time_remain);
      {timer_en, snooze_cnt} =3'b010; #10
      $display("time_remain= %d (expect 0)", uut.time_remain);
      
      //2.2 when timer_en is off, load time_remain
      {timer_en, snooze_cnt} =3'b101; #10
      $display("time_remain= %d (expect 300)", uut.time_remain);
      {timer_en, snooze_cnt} =3'b110; #10
      $display("time_remain= %d (expect 180)", uut.time_remain);      
      
      //2.3 after loading when tick is high, time_remain will reduce 1
      {timer_en, snooze_cnt} =3'b101; #10
      {timer_en, tick} = 2'b01; #10
      $display("time_remain =%d, m1 =%d, m0 =%d,s1 =%d, s0 =%d, (expect 299,0,4,5,9)", uut.time_remain, m1,m0,s1,s0);
      {timer_en, tick} = 2'b00; #10
      $display("time_remain =%d, m1 =%d, m0 =%d,s1 =%d, s0 =%d, (expect 299,0,4,5,9)", uut.time_remain, m1,m0,s1,s0);
      {timer_en, tick} = 2'b01; #10
      $display("time_remain =%d, m1 =%d, m0 =%d,s1 =%d, s0 =%d, (expect 298,0,4,5,8)", uut.time_remain, m1,m0,s1,s0);
      
      //3 Timeout only happens when time remain is 1
      repeat (296) begin
			@(posedge clk); #1 tick = 1;  // wait a tiny delay after the edge
      end
      $display("time_remain =%d, m1 =%d, m0 =%d,s1 =%d, s0 =%d, timeout=%d, (expect 1, 0,0,0,1,0)", uut.time_remain, m1,m0,s1,s0, timeout);
      tick = 1; #10
      $display("time_remain =%d, m1 =%d, m0 =%d,s1 =%d, s0 =%d, timeout=%d, (expect 1, 0,0,0,0,1)", uut.time_remain, m1,m0,s1,s0, timeout);	  
    
    $finish;
    
    end
  
  
endmodule
