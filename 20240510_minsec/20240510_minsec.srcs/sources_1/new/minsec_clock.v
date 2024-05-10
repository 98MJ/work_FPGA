`timescale 1ns / 1ps

module minsec_clock(
    input clk,
    input reset,
    output [7:0] fndFont,
    output [3:0] fndCom
    );

    wire w_clk_1hz, w_clk_min;
    wire [5:0] secData;
    wire [5:0] minData;
    wire [11:0] timeData;

     fndController U_FNDCtrl(
    .reset(reset),
    .clk(clk),
    .digit({2'b0, timeData}),
    .fndFont(fndFont),
    .fndCom(fndCom)
    );

    clkDiv #(.MAX_COUNT(100_000_000)) U_ClkDiv1 (
    .clk(clk),
    .o_clk(w_clk_1hz),
    .reset(reset)
    );

    time_Counter U_CounterSec(
        .clk(w_clk_1hz),
        .reset(reset),
        .c_clk(w_clk_min),
        .o_data(secData)
    );
    time_Counter U_CounterMin(
        .clk(w_clk_min),
        .reset(reset),
        .o_data(minData)
    );

    merge U_merge(
    .a(secData),
    .b(minData),
    .out(timeData)
    );
endmodule

module merge (
    input [5:0] a,
    input [5:0] b,
    output [11:0] out
);
    assign out = a + b * 100;
    
endmodule