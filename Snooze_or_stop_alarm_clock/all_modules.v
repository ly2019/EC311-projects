
//a top module to connect everything
module top(
    input  wire        clk,      
  	input  wire [3:0]  button,         // switches 3:0
    output wire      led,        // LED for carry-out
    output wire [6:0] seg,         // segment pins {g,f,e,d,c,b,a}
  	output wire [7:0] an,          // digit-enable pins
    output wire     dp           // decimal point
);
  
    // 1. assign buttons,
  	wire  reset 	= button[3];    
  	wire  trigger 	= button[2];
  	wire  stop		= button[1] ; 
    wire  snooze	= button[0]; 


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


//The display module
module display(
    input        clk,              
  	input  [4:0] d7, d6, d5, d4, d3, d2, d1, d0,   //  8 4-bit number
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
          	hour	<= 5'd6;
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
