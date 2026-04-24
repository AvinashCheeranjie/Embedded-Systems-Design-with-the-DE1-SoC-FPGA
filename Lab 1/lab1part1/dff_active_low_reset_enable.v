module d_ff_active_low_reset_enable (
	input wire clk,
	input wire reset,
	input wire enable,
	input wire d,
	output reg q

); always @(posedge clk) begin
		if (!reset) 
			q <= 0;
		else if (enable)
			q <= d;
		else
			q <= q;
	end
endmodule