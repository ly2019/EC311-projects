`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2026 12:30:07 PM
// Design Name: 
// Module Name: ticker
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




//The ticker generator module
module ticker #(
    parameter CLK_HZ = 100_000_000, //The clock frenquency
    parameter TICK_HZ= 1           //The tick frequency
)(
	input clk,
  	output tick
);
  	localparam CLK_PER_TICK = CLK_HZ/TICK_HZ;  //set how many clks are needed to tick once
  	reg [26:0] clk_count = 0;
  
  	always @(posedge clk) begin
      	if (clk_count < CLK_PER_TICK -1) clk_count <= clk_count + 1;  //increase clk_count until the end of the cycle (1s)
      	else clk_count <= 0; // reset clk_count to 0 when it reach the end of the cycle (end of 1 s)
    end     
  	assign tick = (clk_count == 0) ? 1: 0;
  
endmodule
