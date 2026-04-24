module d_ff_active_low_reset(
	input wire clk,
	input wire reset,
	input wire d,
	output reg q
		
); always @(posedge clk) begin
		if(!reset) 
			q <= 0;
		else 
			q <= d;
	end
endmodule