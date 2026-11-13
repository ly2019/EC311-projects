`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2026 12:28:54 PM
// Design Name: 
// Module Name: display
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



//The display module
module display(
    input        clk,              
  input  [3:0] d7, d6, d5, d4, d3, d2, d1, d0,   //  8 4-bit number
  	output reg [7:0] an,           // which digit is on (active-low)
 	output [6:0] seg,               // segment pattern {g,f,e,d,c,b,a} (active-low)
  	output reg dp
);

    // set a counter
    reg [19:0] counter = 0;
    always @(posedge clk)
        counter <= counter + 1;

    // use the top 3 bits of counter to pick one digit out of four to display
  	reg [3:0] number;                 // which number to show on the display (8 digit lights)
    always @(*) begin
      dp = 1'b1;
      case (counter[19:17])
            3'd0: begin number = d0; an = 8'b11111110; end   // rightmost digit
            3'd1: begin number = d1; an = 8'b11111101; end
            3'd2: begin number = d2; an = 8'b11111011; dp = 1'b0; end
            3'd3: begin number = d3; an = 8'b11110111; end 
            3'd4: begin number = d4; an = 8'b11101111; end   
            3'd5: begin number = d5; an = 8'b11011111; end
            3'd6: begin number = d6; an = 8'b10111111; dp = 1'b0; end       
        	default:begin number = d7; an = 8'b01111111; end  // leftmost digit
        endcase
    end
  
    // use decoder turn the chosen number into a segment pattern
  	decoder dec(.number(number), .seg(seg));

endmodule
