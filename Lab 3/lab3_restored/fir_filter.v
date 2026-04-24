module fir_filter (input clk, input [15:0] input_sample, output reg signed [15:0] output_sample);
	
	parameter TAPS = 81;
	reg signed [15:0] coeff [0:TAPS-1];
	reg signed [15:0] cascade [0:TAPS-1];	//cascading input
	wire [15:0] res [0:TAPS-1];
	reg signed [31:0] sum;
	
	always @(*) begin
        coeff[  0]=   -1;  coeff[  1]=    0;  coeff[  2]=    3;  coeff[  3]=    0;
        coeff[  4]=   -7;  coeff[  5]=    0;  coeff[  6]=   17;  coeff[  7]=    0;
        coeff[  8]=  -34;  coeff[  9]=    0;  coeff[ 10]=   62;  coeff[ 11]=    0;
        coeff[ 12]= -107;  coeff[ 13]=    0;  coeff[ 14]=  171;  coeff[ 15]=    0;
        coeff[ 16]= -260;  coeff[ 17]=    0;  coeff[ 18]=  377;  coeff[ 19]=    0;
        coeff[ 20]= -523;  coeff[ 21]=    0;  coeff[ 22]=  699;  coeff[ 23]=    0;
        coeff[ 24]= -900;  coeff[ 25]=    0;  coeff[ 26]= 1120;  coeff[ 27]=    0;
        coeff[ 28]=-1349;  coeff[ 29]=    0;  coeff[ 30]= 1576;  coeff[ 31]=    0;
        coeff[ 32]=-1787;  coeff[ 33]=    0;  coeff[ 34]= 1969;  coeff[ 35]=    0;
        coeff[ 36]=-2110;  coeff[ 37]=    0;  coeff[ 38]= 2198;  coeff[ 39]=    0;
        coeff[ 40]=30539;  coeff[ 41]=    0;  coeff[ 42]= 2198;  coeff[ 43]=    0;
        coeff[ 44]=-2110;  coeff[ 45]=    0;  coeff[ 46]= 1969;  coeff[ 47]=    0;
        coeff[ 48]=-1787;  coeff[ 49]=    0;  coeff[ 50]= 1576;  coeff[ 51]=    0;
        coeff[ 52]=-1349;  coeff[ 53]=    0;  coeff[ 54]= 1120;  coeff[ 55]=    0;
        coeff[ 56]= -900;  coeff[ 57]=    0;  coeff[ 58]=  699;  coeff[ 59]=    0;
        coeff[ 60]= -523;  coeff[ 61]=    0;  coeff[ 62]=  377;  coeff[ 63]=    0;
        coeff[ 64]= -260;  coeff[ 65]=    0;  coeff[ 66]=  171;  coeff[ 67]=    0;
        coeff[ 68]= -107;  coeff[ 69]=    0;  coeff[ 70]=   62;  coeff[ 71]=    0;
        coeff[ 72]=  -34;  coeff[ 73]=    0;  coeff[ 74]=   17;  coeff[ 75]=    0;
        coeff[ 76]=   -7;  coeff[ 77]=    0;  coeff[ 78]=    3;  coeff[ 79]=    0;
        coeff[ 80]=   -1;
	end

	genvar i;
	generate
		for(i = 0;i < TAPS;i=i+1) begin: multiply
			multiplier (cascade[i],coeff[i],res[i]);
		end
	endgenerate
	
	integer j;
	integer k;
	
	always @(posedge clk) 
		begin
		for(j = TAPS-1; j > 0; j = j - 1)begin
		
			cascade[j] <= cascade[j-1];
			
		end
		
		cascade[0] <= input_sample;
		
		sum = 0;
		for(k = 0; k < TAPS; k = k + 1) 
		begin	
			sum = sum + res[k];
		end
			output_sample <= sum[15:0];
	end // always
	
endmodule