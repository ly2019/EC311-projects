`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2026 12:34:08 PM
// Design Name: 
// Module Name: alarm_fsm
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




// The alarm fsm module
module alarm_fsm(
  input clk, reset, trigger, snooze, stop, timeout,
  output reg [1:0] snooze_cnt,
  output reg timer_en, buzz
);
  
	// 1. State names and codes
	localparam 	IDLE			=8'b00000001, 
  			 	BUZZ_1			=8'b00000010, 
  			 	SNOOZE_1		=8'b00000100,  
  				SNOOZE_1_WAITING=8'b00001000, 
                BUZZ_2			=8'b00010000, 
  				SNOOZE_2		=8'b00100000,
  				SNOOZE_2_WAITING=8'b01000000, 
  				FINAL_BUZZ		=8'b10000000;
  
  	reg [7:0] state, next; // define current state and next state
 
	//2. Assigning next state based on inputs and current states:
  	always @(posedge clk)
      		if (reset)	state <= IDLE;
        	else     	state <= next;

    // 3. Next-state logic: one case per state
  	always @(*) begin
        case (state)
            IDLE:				if (trigger) next = BUZZ_1; else next = IDLE;
        	BUZZ_1:  			if (stop)  next = IDLE; else if (snooze) next = SNOOZE_1; else next = BUZZ_1;
            SNOOZE_1: 			next = SNOOZE_1_WAITING;
            SNOOZE_1_WAITING: 	if (stop)  next = IDLE; else if (timeout) next = BUZZ_2; else next = 					SNOOZE_1_WAITING;
          	BUZZ_2:		        if (stop)  next = IDLE; else if (snooze) next = SNOOZE_2; else next = BUZZ_2;
            SNOOZE_2: 		 	next = SNOOZE_2_WAITING;
         	SNOOZE_2_WAITING: 	if (stop)  next = IDLE; else if (timeout) next = FINAL_BUZZ; else next = 				SNOOZE_2_WAITING;
         	FINAL_BUZZ:         if (stop)  next = IDLE; else next = FINAL_BUZZ;  
            default: next = IDLE;     
        endcase
    end
    
  	//4. Output logic
	always @(*) begin
        case (state)
           	IDLE:				begin buzz = 0; snooze_cnt = 2'b00; timer_en = 0; end
        	BUZZ_1:  			begin buzz = 1; snooze_cnt = 2'b00; timer_en = 0; end
            SNOOZE_1: 			begin buzz = 0; snooze_cnt = 2'b01; timer_en = 1; end
            SNOOZE_1_WAITING: 	begin buzz = 0; snooze_cnt = 2'b01; timer_en = 0; end
          	BUZZ_2:		        begin buzz = 1; snooze_cnt = 2'b01; timer_en = 0; end
         	SNOOZE_2: 		 	begin buzz = 0; snooze_cnt = 2'b10; timer_en = 1; end
         	SNOOZE_2_WAITING: 	begin buzz = 0; snooze_cnt = 2'b10; timer_en = 0; end
         	FINAL_BUZZ:         begin buzz = 1; snooze_cnt = 2'b10; timer_en = 0; end
            default: 			begin buzz = 0; snooze_cnt = 2'b00; timer_en = 0; end
        endcase    	
    end

endmodule