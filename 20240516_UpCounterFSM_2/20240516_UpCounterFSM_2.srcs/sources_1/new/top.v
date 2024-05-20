`timescale 1ns / 1ps

module top(
    input clk,
    input reset,
    input btn_runStop,
    input btn_clear,
    output [2:0] led,
    output [7:0] fndFont,
    output [3:0] fndCom
    );
    
    wire  w_clk_10hz;
    wire w_run_stop, w_clear;
    wire [13:0] w_digit;

    clkDiv #(.MAX_COUNT(10_000_000)
    ) U_ClkDiv_10hz(
        .clk(clk),
        .reset(reset),
        .o_clk(w_clk_10hz)
    );
    up_counter U_UpCounter(
        .clk(clk),
        .reset(reset),
        .tick(w_clk_10hz),
        .run_stop(w_run_stop),
        .clear(w_clear),
        .count(w_digit)
    );
    fndController U_FndController (
        .clk(clk),
        .reset(reset),
        .digit(w_digit),
        .fndFont(fndFont),
        .fndCom(fndCom)
    );

    button U_Btn_RunStop(
        .clk(clk),
        .in(btn_runStop),
        .out(w_btn_runStop)
    );

    button U_Btn_Clear(
        .clk(clk),
        .in(btn_clear),
        .out(w_bnt_clear)
    );

    control_unit U_ControllUnit(
        .clk(clk),
        .reset(reset),
        .btn_runStop(w_btn_runStop),
        .btn_clear(w_bnt_clear),
        .run_stop(w_run_stop),
        .clear(w_clear),
        .debug_LED(led)
    );


ila_0 U_ILA (
	.clk(clk), // input wire clk
	.probe0(w_btn_runStop), // input wire [0:0]  probe0  
	.probe1(w_bnt_clear), // input wire [0:0]  probe1 
	.probe2(w_run_stop), // input wire [0:0]  probe2 
	.probe3(w_clear), // input wire [0:0]  probe3 
	.probe4(w_digit), // input wire [13:0]  probe4 
	.probe5(fndCom) // input wire [3:0]  probe5
);
endmodule