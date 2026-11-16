`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2026 12:11:25 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



//a top module to connect everything
module top(
    input  wire        clk,      
  	input  wire [3:0]  button,         // button 3:0
    output wire      led,               // LED for buzz
    output wire [6:0] seg,         // segment pins {g,f,e,d,c,b,a}
  	output wire [7:0] an,          // digit-enable pins
    output wire     dp           // decimal point
);
  
 
    // 1. assign buttons,
  	wire  reset 	= button[3];    
  	debouncer debounce_trigger(.clk(clk),.rst(button[3]), .button(button[2]),.debounced_button(trigger));
  	debouncer debounce_stop(.clk(clk),.rst(button[3]), .button(button[1]),.debounced_button(stop));
  	debouncer debounce_snooze(.clk(clk),.rst(button[3]), .button(button[0]),.debounced_button(snooze)); 


    // 2. Wires to digits of time, tick, buzz, snooze count, timer enabler, timeout, 
    wire [3:0] hour1, hour0, minute1, minute0;
  	wire [3:0] m1, m0, s1, s0;
    wire       tick;   
  	wire       timer_en, timeout, buzz;
    wire [1:0] snooze_cnt;

    // 3. The timer
  	timer timeleft(.timer_en(timer_en), .clk(clk), .tick(tick), .snooze_cnt(snooze_cnt), .timeout(timeout), .m1(m1), .m0(m0), .s1(s1), .s0(s0));
                   
    // 4. The clock
  	clock clock(.clk(clk), .tick(tick), .reset(reset), .hour1(hour1), .hour0(hour0), .minute1(minute1), .minute0(minute0));
                
    // 5. The ticker
    ticker ticker(.clk(clk), .tick(tick));
                
    // 6. The alarm FSM
  alarm_fsm fsm(.clk(clk), .reset(reset), .stop(stop), .trigger(trigger), .timeout(timeout), .snooze(snooze), .buzz(buzz), .timer_en(timer_en), .snooze_cnt(snooze_cnt));

    // 7. The display: (left to right)
  	display disp(.clk(clk), .dp(dp), .d7(hour1), .d6(hour0), .d5(minute1), .d4(minute0), .d3(m1), .d2(m0), .d1(s1), .d0(s0),.an(an), .seg(seg));
                
    // 8. led output
    assign led = buzz;   // buzz on LED X

endmodule
