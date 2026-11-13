`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2026 12:30:59 PM
// Design Name: 
// Module Name: clock
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



//The clock module
module clock(
	input clk, reset, tick,
  	output [3:0] hour1, hour0, minute1, minute0 //the digits of the hour and minute
);
  	reg [5:0] second = 0;
  	reg [5:0] hour	= 6'd6; //set the starting time to be 6:58
  	reg [5:0] minute = 6'd58;
  
  	//update the time every second
    always @(posedge clk) 
        if (reset) begin
          	second  <= 0;
          	hour	<= 6'd6;
         	minute  <= 6'd58;
        end
      	else if (tick) begin  //update second at each tick
          	if (second < 59) second <= second + 1;
    		else begin
              	second <= 0;
              	if (minute < 59) minute <= minute + 1;
              	else begin
                	minute <= 0;
                  	hour <= (hour < 23) ? hour +1: 0;
                end
            end
        end
 
  
	assign hour1 = hour / 10;
    assign hour0 = hour % 10;
    assign minute1 = minute / 10;
    assign minute0 = minute % 10;
 
endmodule
