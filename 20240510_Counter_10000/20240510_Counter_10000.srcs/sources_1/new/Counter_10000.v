`timescale 1ns / 1ps

module Count_disp (
    input reset,
    input clk,
    output [3:0] fndCom,
    output [7:0] fndFont
);
    wire [13:0] w_count;
    wire [1:0] w_clk_1hz;

    fndController U_FNDController(
    .clk(clk),
    .reset(reset),
    .digit(w_count),
    .fndFont(fndFont),
    .fndCom(fndCom)
    );

    clkDiv #(.MAX_COUNT(10_000_000)) U_ClkDiv10 (
    .clk(clk),
    .o_clk(w_clk_10hz),
    .reset(reset)
    );

    Counter_10000 U_COUNTER(
    .clk(w_clk_10hz),
    .reset(reset),
    .count(w_count)
    );    
endmodule

module Counter_10000(
    input clk,
    input reset,
    output [$clog2(10000)-1:0] count
    );

    reg [$clog2(10000)-1:0] counter = 0;
    assign count = counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else begin
            if(counter == 10000) begin
                counter <= 0;
            end
            else begin
                counter <= counter + 1;
            end
        end
    end



endmodule
