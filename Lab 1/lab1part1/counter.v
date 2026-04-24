module counter(
	input wire clk,
	input wire reset,
	input wire enable,
	output reg [3:0] count_out
); always @(posedge clk) begin
		if (reset == 1'b1) 
			count_out <= 4'b0000;
		else if (enable == 1'b1) 
			count_out <= count_out + 1;
	end
endmodule