//The requirements for the project:

// 1. Key1 for reset, Key2 for resume, Key0 is player 1, Key3 is for player 2
// 2. If Key0 is pressed earlier than Key3, player 1 wins. If Key3 is pressed earlier, player2 wins.
// 3. If Key0 and Key3 pressed at the same time, no one wins. 
// 4. If player1 wins, one more LEDs of the LED0-4 will light up.If player2 wins, one more LEDs of the LED=9-5 will light up,  
// 5. After power up, or after reset, all of LEDs are off. the HEXs will blink for 5 seconds. then will be off for  2+randdom seconds.
		//Here the random ranges form 1 sec to 5 sec
// 6. The winner's reaction time will show by the HEXs.
//	7. If there is a cheating (press the KEY0 or KEY3 before the timer starts,(in program, (set that if the timer reading is less than 
		//80 ms, it is cheating)
		//the cheater's number, either 111111 or 222222 will show by HEXs. The program then stop for resumeing for next round.
//	8. if both player is cheating at the same time (or both player pressed at the same time, which is not likely to happen), display 888888 by HEXs and then wait to resume the game.

`default_nettype none

module lab2(
    input  wire       CLOCK_50,
    input  wire [3:0] KEY,                 
    output wire [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,
    output wire [9:0] LEDR
);

    localparam [2:0]
        RESET_S  = 3'd0,
        RESUME_S = 3'd1,
        BLINK_S  = 3'd2,
        OFF_S    = 3'd3,
        TIMER_S  = 3'd4,
        SHOW_S   = 3'd5,
        HOLD_S   = 3'd6;   // cheating 

    localparam integer BLINK_MS  = 5000;
    localparam integer FIXED_OFF = 2000;
    localparam integer CHEAT_MS  = 80;

    reg [2:0] state = RESET_S, next_state = RESET_S;

    // 1ms clock
    wire clk_ms;
    clock_divider #(.factor(50000)) u_div (
        .clock (CLOCK_50),
        .reset (KEY[1]),
        .clk_ms(clk_ms)
    );

    // ms since last KEY2 press
    wire [19:0] ms;
    counter u_ms (
        .clock     (clk_ms),
        .reset (KEY[1]),
        .resume (KEY[2]),
        .enable  (1'b1),
        .ms_count(ms)
    );

    // blinkHEX
    wire [3:0] b0,b1,b2,b3,b4,b5;
    blinkHEX #(.factor(200)) u_blink (
        .ms_clk (clk_ms),
        .Reset_n(KEY[1]),
        .d0(b0), .d1(b1), .d2(b2),
        .d3(b3), .d4(b4), .d5(b5)
    );

    // reaction timer 
    reg  display_counter_start;
    wire [19:0] display_ms;
    counter u_disp (
        .clock     (clk_ms),
        .reset (KEY[1]),
        .resume (KEY[2]),
        .enable  (display_counter_start),
        .ms_count(display_ms)
    );

    // RNG instantiation 
    wire [13:0] rng_value;
    wire        rng_ready;

    random u_rng (
        .clk      (clk_ms),
        .reset_n  (KEY[1]),
        .resume_n (KEY[2]),
        .random   (rng_value),
        .rnd_ready(rng_ready)
    );

    // latch RNG output once per round
    reg [13:0] random_wait_ms;
    reg        random_valid;

    always @(posedge clk_ms or negedge KEY[1] or negedge KEY[2]) begin
        if (!KEY[1] || !KEY[2]) begin
            random_valid   <= 1'b0;
            random_wait_ms <= 14'd1000; // safe default
        end else begin
            if (!random_valid && rng_ready) begin
                random_wait_ms <= rng_value;   // 1000-5000 from RNG
                random_valid   <= 1'b1;
            end
        end
    end

    // LED Scoreboard
    reg [4:0] win1, win2;
    reg p1_win_pulse, p2_win_pulse;

    assign LEDR[4:0] = win1;
    assign LEDR[9:5] = {win2[0],win2[1],win2[2],win2[3],win2[4]};

    always @(posedge clk_ms or negedge KEY[1]) begin
        if (!KEY[1]) begin
            win1 <= 5'b0;
            win2 <= 5'b0;
        end else begin
            if (p1_win_pulse) win1 <= (win1 << 1) | 5'b00001;
            if (p2_win_pulse) win2 <= (win2 << 1) | 5'b00001;
        end
    end

    // winner time & code
    reg [19:0] winner_time;
    reg [1:0]  code; // 0 normal, 1=111111, 2=222222, 3=888888

    always @(posedge clk_ms or negedge KEY[1] or negedge KEY[2]) begin
        if (!KEY[1] || !KEY[2]) begin
            winner_time <= 20'd0;
            code        <= 2'd0;
        end else if (state == TIMER_S) begin
            if (!KEY[0] && !KEY[3]) begin
                code        <= 2'd3;         // tie
                winner_time <= display_ms;
            end else if (!KEY[0] || !KEY[3]) begin
                winner_time <= display_ms;

                if (display_ms < CHEAT_MS) begin
                    if (!KEY[0] &&  KEY[3])      code <= 2'd1; // P1 cheat
                    else if ( KEY[0] && !KEY[3]) code <= 2'd2; // P2 cheat
                    else                         code <= 2'd3;
                end else begin
                    code <= 2'd0; // normal
                end
            end
        end
    end

    // hex to bcd converters
    wire [3:0] t0,t1,t2,t3,t4,t5;
    wire [3:0] w0,w1,w2,w3,w4,w5;

    hex_to_bcd_converter u_conv_timer (
        .clock(CLOCK_50),
        .hex_number(display_ms),
        .bcd_digit_0(t0), .bcd_digit_1(t1), .bcd_digit_2(t2),
        .bcd_digit_3(t3), .bcd_digit_4(t4), .bcd_digit_5(t5)
    );

    hex_to_bcd_converter u_conv_winner (
        .clock(CLOCK_50),
        .hex_number(winner_time),
        .bcd_digit_0(w0), .bcd_digit_1(w1), .bcd_digit_2(w2),
        .bcd_digit_3(w3), .bcd_digit_4(w4), .bcd_digit_5(w5)
    );

    // HEX mux 
    reg [3:0] digit0,digit1,digit2,digit3,digit4,digit5;

    always @(*) begin
        digit0=4'hF; digit1=4'hF; digit2=4'hF;
        digit3=4'hF; digit4=4'hF; digit5=4'hF;

        case (state)
            BLINK_S: begin
                digit0=b0; digit1=b1; digit2=b2;
                digit3=b3; digit4=b4; digit5=b5;
            end

            OFF_S: begin
               // all OFF
            end

            TIMER_S: begin
                digit0=t0; digit1=t1; digit2=t2;
                digit3=t3; digit4=t4; digit5=t5;
            end

            SHOW_S: begin
                digit0=w0; digit1=w1; digit2=w2;
                digit3=w3; digit4=w4; digit5=w5;
            end

            HOLD_S: begin
                if (code == 2'd1) begin
                    digit0=4'd1; digit1=4'd1; digit2=4'd1; digit3=4'd1; digit4=4'd1; digit5=4'd1;
                end else if (code == 2'd2) begin
                    digit0=4'd2; digit1=4'd2; digit2=4'd2; digit3=4'd2; digit4=4'd2; digit5=4'd2;
                end else begin
                    digit0=4'd8; digit1=4'd8; digit2=4'd8; digit3=4'd8; digit4=4'd8; digit5=4'd8;
                end
            end
        endcase
    end

    seven_seg_decoder dec0(digit0, HEX0);
    seven_seg_decoder dec1(digit1, HEX1);
    seven_seg_decoder dec2(digit2, HEX2);
    seven_seg_decoder dec3(digit3, HEX3);
    seven_seg_decoder dec4(digit4, HEX4);
    seven_seg_decoder dec5(digit5, HEX5);

    // state register
    always @(posedge clk_ms or negedge KEY[1] or negedge KEY[2]) begin
        if (!KEY[1])      state <= RESET_S;
        else if (!KEY[2]) state <= RESUME_S;
        else              state <= next_state;
    end

    // FSM logic
    always @(*) begin
        next_state = state;

        display_counter_start = 1'b0;
        p1_win_pulse = 1'b0;
        p2_win_pulse = 1'b0;

        case (state)
            RESET_S:  next_state = BLINK_S;
            RESUME_S: next_state = BLINK_S;

            BLINK_S: begin
                if (ms >= BLINK_MS) next_state = OFF_S;
            end

            OFF_S: begin
                // wait until we latched a valid RNG value
                if (random_valid && (ms >= (BLINK_MS + FIXED_OFF + random_wait_ms)))
                    next_state = TIMER_S;
            end

            TIMER_S: begin
                display_counter_start = 1'b1;

                if (!KEY[0] && !KEY[3]) begin
                    next_state = HOLD_S; // 888888
                end else if (!KEY[0] || !KEY[3]) begin
                    if (display_ms < CHEAT_MS) begin
                        next_state = HOLD_S; // 111111 / 222222
                    end else begin
                        if (!KEY[0] &&  KEY[3])      p1_win_pulse = 1'b1;
                        else if ( KEY[0] && !KEY[3]) p2_win_pulse = 1'b1;
                        next_state = SHOW_S;         // show winner time
                    end
                end
            end

            SHOW_S: next_state = SHOW_S; // wait for KEY2
            HOLD_S: next_state = HOLD_S; // wait for KEY2

            default: next_state = RESET_S;
        endcase
    end
endmodule

`default_nettype wire




