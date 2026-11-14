`timescale 1ns / 1ps

module alarm_fsm_simple_tb();
    reg  clk = 0, reset = 0;
    reg  trigger = 0, snooze = 0, stop = 0, timeout = 0;
    wire [1:0] snooze_cnt;
    wire       timer_en, buzz;

    alarm_fsm uut(.clk(clk), .reset(reset), .trigger(trigger),
                  .snooze(snooze), .stop(stop), .timeout(timeout),
                  .snooze_cnt(snooze_cnt), .timer_en(timer_en), .buzz(buzz));
  
  	//NAME each state so it can be more readable when printed.
	function [8*16:1] name;                 // up to 16 characters
    input [7:0] s;
    case (s)
        8'h01:   name = "IDLE";
        8'h02:   name = "BUZZ_1";
        8'h04:   name = "SNOOZE_1";
        8'h08:   name = "SNOOZE_1_WAITING";
        8'h10:   name = "BUZZ_2";
        8'h20:   name = "SNOOZE_2";
        8'h40:   name = "SNOOZE_2_WAITING";
        8'h80:   name = "FINAL_BUZZ";
        default: name = "INVALID";
    endcase
	endfunction

    always #5 clk = ~clk;

  
  	    // waveform dump
    //initial begin
    //    $dumpfile("dump.vcd");                       // file name
    //    $dumpvars(0, alarm_fsm_simple_tb);           // 0 = all levels, including inside the FSM
  //  end

    initial begin
    //1. test outputs given a state
    reset = 1;
    uut.state = 8'h1;#1
    $display("IDLE: buzz=%b snooze_cnt=%b timer_en=%b (expect buzz=0, snooze_cnt=00, timer_en=0)", buzz, snooze_cnt, timer_en);
    uut.state = 8'h2;#1
    $display("BUZZ_1: buzz=%b snooze_cnt=%b timer_en=%b (expect buzz=1, snooze_cnt=00, timer_en=0)", buzz, snooze_cnt, timer_en);
	uut.state = 8'h4;#1
    $display("SNOOZE_1: buzz=%b snooze_cnt=%b timer_en=%b (expect buzz=0, snooze_cnt=01, timer_en=1)", buzz, snooze_cnt, timer_en);
    uut.state = 8'h8;#1
    $display("SNOOZE_1_WAITING: buzz=%b snooze_cnt=%b timer_en=%b (expect buzz=0, snooze_cnt=01, timer_en=0)", buzz, snooze_cnt, timer_en);
    uut.state = 8'h10;#1
    $display("BUZZ_2: buzz=%b snooze_cnt=%b timer_en=%b (expect buzz=1, snooze_cnt=01, timer_en=0)", buzz, snooze_cnt, timer_en);
    uut.state = 8'h20;#1
    $display("SNOOZE_2: buzz=%b snooze_cnt=%b timer_en=%b (expect buzz=0, snooze_cnt=10, timer_en=1)", buzz, snooze_cnt, timer_en);
    uut.state = 8'h40;#1
    $display("SNOOZE_2_WAITING: buzz=%b snooze_cnt=%b timer_en=%b (expect buzz=0, snooze_cnt=10, timer_en=0)", buzz, snooze_cnt, timer_en); 
    uut.state = 8'h80;#1
    $display("FINAL_BUZZ: buzz=%b snooze_cnt=%b timer_en=%b (expect buzz=1, snooze_cnt=10, timer_en=0)", buzz, snooze_cnt, timer_en); 
      
      
    //2. test next state based on current state and inputs
      
    //S0: IDLE
    $display("IDLE");
    reset = 1; #2
    reset = 0;
    uut.state = 8'h1;
    trigger = 0; #10;
    $display("IDLE + trigger(0)-->IDLE: state=%0s", name(uut.state) );
    trigger = 1; #10;
      $display("IDLE + trigger(1)-->BUZZ_1: state=%0s", name(uut.state));

    //S1: BUZZ_1
    $display("BUZZ_1");
    uut.state = 8'h2;
    {stop, snooze} = 2'b00; #10;
      $display("BUZZ_1 + stop(0) + snooze(0)--> BUZZ_1: state=%0s ", name(uut.state) );
    uut.state = 8'h2;
    {stop, snooze} = 2'b10; #10;
      $display("BUZZ_1 + stop(1) + snooze(0)-->IDLE: state=%0s",  name(uut.state));
    uut.state = 8'h2;
    {stop, snooze} = 2'b11; #10;
      $display("BUZZ_1 + stop(1) + snooze (1)-->IDLE: state=%0s",  name(uut.state));
    uut.state = 8'h2;
    {stop, snooze} = 2'b01; #10;
      $display("BUZZ_1 + snooze(1)-->SNOOZE_1: state=%0s",  name(uut.state));

    //S2: SNOOZE_1
    $display("SNOOZE_1");
    uut.state = 8'h4;
    {stop, snooze} = 2'b10; #10; //stop won't stop it
     $display("SNOOZE_1 + stop(1) + snooze(0)--> SNOOZE_1_WAITING: state=%0s", name(uut.state));
    uut.state = 8'h4;
    {stop, snooze} = 2'b00; #10;
      $display("SNOOZE_1 + stop(0) + snooze(0)--> SNOOZE_1_WAITING: state=%0s", name(uut.state));

    //S3: SNOOZE_1_WAITING
    $display("SNOOZE_1_WAITING");
    uut.state = 8'h8;
    {stop, snooze, timeout} = 3'b100; #10;
    $display("SNOOZE_1_WAITING + stop(1) + snooze(0) + timeout(0)--> IDLE: state=%0s", name(uut.state));
    uut.state = 8'h8;
    {stop, snooze, timeout} = 3'b010; #10; //snooze won't change it
    $display("SNOOZE_1_WAITING + stop(0) + snooze(1) + timeout(0) --> SNOOZE_1_WAITING: state=%0s", name(uut.state) );
    uut.state = 8'h8;
    {stop, snooze, timeout} = 3'b001; #10;
    $display("SNOOZE_1_WAITING + stop(0) + snooze(0) + timeout(1) --> BUZZ_2: state=%0s", name(uut.state) );
      
    //S4: BUZZ_2
    $display("BUZZ_2");
    uut.state = 8'h10;
    {stop, snooze} = 2'b00; #10;
      $display("BUZZ_2 + stop(0) + snooze(0)--> BUZZ_2: state=%0s ", name(uut.state) );
    uut.state = 8'h10;
    {stop, snooze} = 2'b10; #10;
      $display("BUZZ_2 + stop(1) + snooze(0)-->IDLE: state=%0s",  name(uut.state));
    uut.state = 8'h10;
    {stop, snooze} = 2'b11; #10;
      $display("BUZZ_2 + stop(1) + snooze (1)-->IDLE: state=%0s",  name(uut.state));
    uut.state = 8'h10;
    {stop, snooze} = 2'b01; #10;
      $display("BUZZ_2 + snooze(1)-->SNOOZE_2: state=%0s",  name(uut.state));
    
     //S5: SNOOZE_2
     $display("SNOOZE_2");
    uut.state = 8'h20;
    {stop, snooze} = 2'b10; #10; //stop won't stop it
      $display("SNOOZE_2 + stop(1) + snooze(0)--> SNOOZE_2_WAITING: state=%0s", name(uut.state));
    uut.state = 8'h20;
    {stop, snooze} = 2'b00; #10;
      $display("SNOOZE_2 + stop(0) + snooze(0)--> SNOOZE_2_WAITING: state=%0s", name(uut.state));

    //S6: SNOOZE_2_WAITING
      $display("SNOOZE_2_WAITING");
    uut.state = 8'h40;
    {stop, snooze, timeout} = 3'b100; #10;
      $display("SNOOZE_2_WAITING + stop(1) + snooze(0) + timeout(0)--> IDLE: state=%0s", name(uut.state));
    uut.state = 8'h40;
    {stop, snooze, timeout} = 3'b010; #10; //snooze won't change it
      $display("SNOOZE_2_WAITING + stop(0) + snooze(1) + timeout(0) --> SNOOZE_2_WAITING: state=%0s", name(uut.state) );
    uut.state = 8'h40;
    {stop, snooze, timeout} = 3'b001; #10;
      $display("SNOOZE_2_WAITING + stop(0) + snooze(0) + timeout(1) --> FINAL_BUZZ: state=%0s", name(uut.state) );
    
    //S7: FINAL_BUZZ
      $display("FINAL_BUZZ"); 
     uut.state = 8'h80;
     {stop,snooze} = 2'b01; #10; //snooze won't snooze it
      $display("FINAL_BUZZ + stop(0) + snooze(1)--> FINAL_BUZZ: state=%0s ", name(uut.state) );
          uut.state = 8'h80;
      {stop,snooze} = 2'b10; #10; //Stop 
      $display("FINAL_BUZZ + stop(1) + snooze(0)--> IDLE: state=%0s ", name(uut.state) );
          uut.state = 8'h80;
      {stop,snooze} = 2'b00;#10;  
      $display("FINAL_BUZZ + stop(0) + snooze(0)--> FINAL_BUZZ: state=%0s ", name(uut.state) );

    
    $finish;
    
    end
  
  
endmodule
