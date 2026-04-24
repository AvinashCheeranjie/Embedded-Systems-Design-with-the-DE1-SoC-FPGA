`default_nettype none

module rng(
    input  wire       CLOCK_50,  
    input  wire [3:0] KEY,      
    output wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 
);

    // 1 ms clock (from 50 MHz clock)
    wire clk_ms;
    clock_divider #(.factor(50000)) u_div (
        .clock (CLOCK_50),
        .reset (KEY[1]),  
        .clk_ms(clk_ms)
    );

    // Random number generator 
    wire [13:0] random_number;
    wire rnd_ready;
    
    random u_random (
        .clk       (clk_ms),
        .reset_n   (KEY[1]),
        .resume_n  (KEY[0]),
        .random    (random_number),
        .rnd_ready (rnd_ready)
    );
	 
	 reg [19:0] display_number;
	 reg display_clear;

    always @(posedge clk_ms or negedge KEY[1] or negedge KEY[0]) begin
        if (!KEY[1]) begin
            // If KEY1 is pressed, clear display 
            display_clear <= 1'b1;
            display_number <= 20'b0;  // 000000
        end else if (!KEY[0]) begin
			if (rnd_ready) begin
            display_clear <= 1'b0;
            display_number <= {6'b0, random_number}; 
			end 
		end
    end // always 

    // Convert 20-bit binary number to BCD format for 6 digits
    wire [3:0] d0, d1, d2, d3, d4, d5;
    hex_to_bcd_converter u_converter (
        .clock       (CLOCK_50),
        .hex_number (display_number),
        .bcd_digit_0(d0), .bcd_digit_1(d1), .bcd_digit_2(d2),
        .bcd_digit_3(d3), .bcd_digit_4(d4), .bcd_digit_5(d5)
    );

    // Mux to select which digits to display
    reg [3:0] digit0, digit1, digit2, digit3, digit4, digit5;

    always @(*) begin
        // Default: 0's
        digit0 = 4'b0;
        digit1 = 4'b0;
        digit2 = 4'b0;
        digit3 = 4'b0;
        digit4 = 4'b0;
        digit5 = 4'b0;

        // Display random number if not in clear mode
        if (!display_clear) begin
            digit0 = d0;
            digit1 = d1;
            digit2 = d2;
            digit3 = d3;
            digit4 = d4;
            digit5 = d5;
        end
    end

    // Drive the HEX displays with the selected digits
    seven_seg_decoder dec0(digit0, HEX0);
    seven_seg_decoder dec1(digit1, HEX1);
    seven_seg_decoder dec2(digit2, HEX2);
    seven_seg_decoder dec3(digit3, HEX3);
    seven_seg_decoder dec4(digit4, HEX4);
    seven_seg_decoder dec5(digit5, HEX5);

endmodule

`default_nettype wire
