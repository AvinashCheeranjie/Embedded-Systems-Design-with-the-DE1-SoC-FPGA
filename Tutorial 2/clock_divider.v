module clock_divider (input clock, reset, output reg clk_ms);

	parameter factor = 50000;
	reg [31:0] countQ;
	
	always @ (posedge clock, negedge reset) begin
	
		if (!reset) begin
			countQ <= 32'b0;
		end
		
		else 
			begin 
				countQ <= countQ + 32'd1;
				if(countQ>=(factor-1))
					countQ <= 32'd0;
				clk_ms <= (countQ < factor/2) ? 1'b1:1'b0;
			end
	
	end
	
endmodule