module four_to_one_mux(
	input wire data0,
	input wire data1,
	input wire data2,
	input wire data3,
	input wire sel0,
	input wire sel1,
	output wire data_out
);	assign data_out = (!sel1 && !sel0) ? data0 : 
							(!sel1 &&  sel0) ? data1 : 
							(sel1 &&  !sel0) ? data2 : 
													 data3;
													 
endmodule 