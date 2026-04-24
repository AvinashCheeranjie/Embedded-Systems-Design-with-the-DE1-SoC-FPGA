module d_latch_sync_enable_ctrl(
	input wire en,
	input wire clk,
	input wire d,
	output reg q
); 
	reg en_ctrl;
	//sync enable control
	always @(posedge clk) begin
		en_ctrl <= en;
	end
	//feed to latch
	always @(*) begin
			if (en_ctrl)
				q = d;
	end
endmodule 