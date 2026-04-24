module lab1part1(
    input  wire clk,
    input  wire reset,
    input  wire enable,
    input  wire d,
    input  wire sel0,
    input  wire sel1,
    input  wire data0,
    input  wire data1,
    input  wire data2,
    input  wire data3,
    output wire mux_out,
    output wire q,
    output wire [3:0] count_out
);

    // D flip-flop with active-low reset and enable
    d_ff_active_low_reset_enable u_ff (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .d(d),
        .q(q)
    );

    // 4-to-1 mux
    four_to_one_mux u_mux (
        .data0(data0),
        .data1(data1),
        .data2(data2),
        .data3(data3),
        .sel0(sel0),
        .sel1(sel1),
        .data_out(mux_out)
    );

    // Counter
    counter u_counter (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .count_out(count_out)
    );

endmodule
