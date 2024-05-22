`timescale 1ns / 1ps

module adder(
    input clk,
    input reset,
    input valid,
    input [3:0] a,
    input [3:0] b,
    output [3:0] sum,
    output carry
    );

    reg [3:0] sum_next, sum_reg;
    reg carry_next, carry_reg;

    assign sum = sum_reg;
    assign carry = carry_reg;

    always @(posedge clk , posedge reset) begin
        if (reset) begin
            carry_reg <= 0;
            sum_reg <= 0;
        end else begin
            carry_reg <= carry_next;
            sum_reg <= sum_next;
        end   
    end

    always @(*) begin
        carry_next = carry_reg;
        sum_next = sum_reg;
        if (valid) begin
            {carry_next, sum_next} = a + b;
        end
    end

endmodule
