`timescale 1ns / 1ps

module ClockCounter(
    input sw,
    input reset,
    input clk,
    output [7:0] fndFont,
    output [3:0] fndCom
    );

    wire w_clk_1hz, w_clk_min, w_clk_1khz, w_clk_10hz;
    wire [5:0] secData, minData;
    wire [1:0] w_count;
    wire [3:0] secUnits, secTens, minUnits, minTens;
    wire [3:0] timeData, counterData, w_bcd;
    wire [3:0] _digit_1, _digit_10, _digit_100, _digit_1000;
    wire [13:0] w_countData;

    clkDiv #(.MAX_COUNT(100_000)) U_ClkDiv (
    .clk(clk),
    .o_clk(w_clk_1khz),
    .reset(reset)
    );   

    clkDiv #(.MAX_COUNT(10_000_000)) U_Clk10Hz(
        .clk(clk),
        .o_clk(w_clk_10hz),
        .reset(reset)
    );

    counter #(.MAX_COUNT(4)) U_Counter_2bit(
        .clk(w_clk_1khz),
        .reset(reset),
        .count(w_count)
    );

    clkDiv #(.MAX_COUNT(100_000_000))U_sec(
        .clk(clk),
        .o_clk(w_clk_1hz),
        .reset(reset)
    );

    time_Counter U_secTime(
        .clk(w_clk_1hz),
        .reset(reset),
        .c_clk(w_clk_min),
        .o_data(secData)
    );
    time_Counter U_minTime(
        .clk(w_clk_min), 
        .reset(reset),
        .o_data(minData)
    );

    digitSplitter U_secDisp(
        .i_digit(secData),
        .o_digit_1(secUnits),
        .o_digit_10(secTens)
    );
    digitSplitter U_minDisp(
        .i_digit(minData),
        .o_digit_1(minUnits),
        .o_digit_10(minTens)
    );
    
    mux_21 U_2x1MUX(
        .sel(sw),
        .x0(timeData),
        .x1(counterData),
        .y(w_bcd)
    );

    mux U_4x1MUX(
        .sel(w_count),
        .x0(secUnits),
        .x1(secTens),
        .x2(minUnits),
        .x3(minTens),
        .y(timeData)
    );

    Counter_10000 U_Counter(
        .clk(w_clk_10hz),
        .reset(reset),
        .count(w_countData)
    );
    digitSplitter U_CounterSplit(
        .i_digit(w_countData),
        .o_digit_1(_digit_1),
        .o_digit_10(_digit_10),
        .o_digit_100(_digit_100),
        .o_digit_1000(_digit_1000)
    );
    mux U_4x1MUX_Counter(
        .sel(w_count),
        .x0(_digit_1),
        .x1(_digit_10),
        .x2(_digit_100),
        .x3(_digit_1000),
        .y(counterData)
    );

    BDCtoSEG U_BcdToSeg(
        .bcd(w_bcd),
        .seg(fndFont)
    );
     Decoder_2_4 U_Decoder_24(
        .i(w_count),
        .o(fndCom)
    );

endmodule

