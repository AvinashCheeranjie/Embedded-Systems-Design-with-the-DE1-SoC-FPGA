module mux3 (
    input  [15:0] in0,
    input  [15:0] in1,
    input  [15:0] in2,
    input  [1:0]  sel,
    output reg [15:0] out
);

    always @(*) begin
        case (sel)
            2'b00: out = in0; // direct input
            2'b01: out = in1; // FIR filter output
            2'b10: out = in2; // echo machine output
            default: out = in0;   
        endcase
    end

endmodule