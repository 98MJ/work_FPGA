`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/09 15:10:41
// Design Name: 
// Module Name: Decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Decoder_2_4(
        input [1:0] i,
        output reg [3:0] o
    );

    always @(i) begin
        case (i)
            2'b00 : o = 4'b1110;
            2'b01 : o = 4'b1101;
            2'b10 : o = 4'b1011;
            2'b11 : o = 4'b0111;
        endcase
        
    end
endmodule
