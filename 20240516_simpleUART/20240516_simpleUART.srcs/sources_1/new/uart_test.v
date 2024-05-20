`timescale 1ns / 1ps

module uart_test(
    input clk,
    input reset,
    input btn_start,
    output txd
    );

    wire w_btn_start;

    button U_Btn_Start(
        .clk(clk),
        .in(btn_start),
        .out(w_btn_start)
    );

    uart U_UART_TX(
        .clk(clk),
        .reset(reset),
        .start(1'b1),
        .tx_data(8'h51),
        .tx_done(),
        .txd(txd)
    );
endmodule
