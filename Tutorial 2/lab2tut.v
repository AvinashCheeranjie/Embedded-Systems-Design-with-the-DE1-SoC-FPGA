module lab2tut (input CLOCK_50, input [2:0] KEY, output [6:0] HEX0, HEX1, HEX2,
HEX3, HEX4, HEX5);

	wire clock_1khz;			
	wire [19:0] counter_hex; 
	wire [3:0] bcd0, bcd1, bcd2, bcd3, bcd4, bcd5;
	
	clock_divider clk1(.clock(CLOCK_50), 
							 .reset(KEY[0]), 
							 .clk_ms(clock_1khz));
	
	counter co1(.clock(clock_1khz),
					.reset(KEY[0]),
					.start(KEY[2]),
					.stop(KEY[1]),
					.ms_count(counter_hex));
								
	hex_to_bcd_converter	h1(.clock(clock_1khz),
									.hex_number(counter_hex),
									.bcd_digit_0(bcd0),
									.bcd_digit_1(bcd1),
									.bcd_digit_2(bcd2),
									.bcd_digit_3(bcd3),
									.bcd_digit_4(bcd4),
									.bcd_digit_5(bcd5));
									
	seven_seg_decoder d0(.x(bcd0), .hex_LEDs(HEX0));
	seven_seg_decoder d1(.x(bcd1), .hex_LEDs(HEX1));
	seven_seg_decoder d2(.x(bcd2), .hex_LEDs(HEX2));
	seven_seg_decoder d3(.x(bcd3), .hex_LEDs(HEX3));
	seven_seg_decoder d4(.x(bcd4), .hex_LEDs(HEX4));
	seven_seg_decoder d5(.x(bcd5), .hex_LEDs(HEX5));
								
endmodule