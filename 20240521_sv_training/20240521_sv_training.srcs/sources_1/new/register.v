`timescale 1ns / 1ps

module register(
    input clk,
    input reset,
    input [15:0] i_data,
    output [15:0] o_data
    );

    reg [15:0] data_next, data_reg;

    assign o_data = data_reg;

    always @(posedge clk, posedge reset) begin
        if(reset)begin
            data_reg <= 0;
        end else begin
            data_reg <= data_next;
        end
    end

    always @(*) begin
        data_next = i_data;
    end

endmodule
