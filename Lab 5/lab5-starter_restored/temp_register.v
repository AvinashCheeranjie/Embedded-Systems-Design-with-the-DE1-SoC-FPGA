module temp_register (input clk, reset_n, load, increment, decrement, input [7:0] data,
							 output negative, positive, zero);

	reg signed [7:0] counter /*synthesis keep*/;
					
	always @(posedge clk) begin
	
		if (!reset_n) counter <= 1'b0;
		else if (load) counter <= data;
		else if (increment) counter <= counter + 8'b00000001;
		else if (decrement) counter <= counter - 8'b00000001;
		
	end
	
	// status outputs 
	assign negative = (counter < 0);
   assign zero     = (counter == 0);
   assign positive = (counter > 0);
					
endmodule
