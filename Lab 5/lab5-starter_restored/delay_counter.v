module delay_counter (input clk, reset_n, start, enable, input [7:0] delay, output done);
	parameter BASIC_PERIOD=20'd500000;   // can change this value to make delay longer

    reg [7:0] downcount;
    reg [19:0] timer;

    always @(posedge clk) begin
	 
        if (!reset_n) begin
            timer <= 20'd0;
            downcount <= 8'd0;
        end
		  
        else if (start) begin
            timer <= 20'd0;
            downcount <= delay;
        end
		  
        else if (enable) begin
            if (downcount != 8'd0) begin
                if (timer == BASIC_PERIOD - 1) begin
                    timer <= 20'd0;
                    downcount <= downcount - 8'd1;
                end
					 
                else begin
                    timer <= timer + 20'd1;
                end
            end
				
            else begin
                timer <= 20'd0;
            end
        end
		  
        else begin
            timer <= 20'd0;
        end
		  
    end

    assign done = enable && (downcount == 8'd0);
	 
endmodule