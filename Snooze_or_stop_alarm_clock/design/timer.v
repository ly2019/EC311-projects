`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2026 12:31:41 PM
// Design Name: 
// Module Name: timer
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



//The timer module
module timer(
	input timer_en, clk, tick,
	input [1:0] snooze_cnt,
	output timeout,  
  	output [3:0] m1, m0, s1, s0 //the digits of the left minutes and seconds
);
	//set the countdown through a lookup
	wire [9:0] snooze_time	=	(snooze_cnt == 2'b01)? 'd300: //300s if it is the first snooze 
	(snooze_cnt == 2'b10)? 'd180: //180s if it is the second snooze
     				 									'd0;
  	reg [9:0] time_remain = 0;
  
  	//update the time_remain every second
    always @(posedge clk) 
      	if (timer_en)  time_remain <= snooze_time;
		else if (tick) begin  //update the time remain at each tick
          	if (snooze_cnt > 0) time_remain <= (time_remain > 0 ) ? time_remain -1: 0; 
    		else time_remain <= 0;
        end
  
  	//minutes and seconds to be displayed. this is unnessary but just writing them for checking
  	wire [5:0] minute_remain = time_remain / 60;
  	wire [5:0] second_remain = time_remain % 60;
  	
  	assign m1 = minute_remain / 10;
    assign m0 = minute_remain % 10;
    assign s1 = second_remain / 10;
    assign s0 = second_remain % 10;
      
  	//update timeout when only 1s left
 	assign timeout = (time_remain == 1 && tick) ? 'b1: 'b0;
  
endmodule
