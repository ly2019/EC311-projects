`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2026 12:29:27 PM
// Design Name: 
// Module Name: decoder
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



//Decoder. This module is to convert the input, a 4-bit value (0-9), into a 7-segment display pattern
// Segments are active-low (0 = on).
//      a
//     ---
//  f |   | b
//     -g-
//  e |   | c
//     ---
//      d
//
// seg[6:0] = {g, f, e, d, c, b, a}
module decoder(
  input [3:0] number,
  output reg [6:0] seg
);
  always @(*) begin
    case (number)
      4'h0: seg = 7'b1000000;   // 0
      4'h1: seg = 7'b1111001;   // 1
      4'h2: seg = 7'b0100100;   // 2
      4'h3: seg = 7'b0110000;   // 3
      4'h4: seg = 7'b0011001;   // 4
      4'h5: seg = 7'b0010010;   // 5
      4'h6: seg = 7'b0000010;   // 6
      4'h7: seg = 7'b1111000;   // 7
      4'h8: seg = 7'b0000000;   // 8
      4'h9: seg = 7'b0010000;   // 9
      default: seg = 7'b1111111; // all segments off
    endcase
  end
endmodule


