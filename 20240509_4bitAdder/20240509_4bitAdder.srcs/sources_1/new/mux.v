`timescale 1ns / 1ps

module mux(
    input       [1:0] sel,
    input       [3:0] x0,
    input       [3:0] x1,
    input       [3:0] x2,
    input       [3:0] x3,
    output reg  [3:0] y
    );

    always @(*) begin // always @(sel, x0, x1, x2, x3) *은 모든 값 감시
        case (sel)  
            2'b00: y=x0;
            2'b01: y=x1;
            2'b10: y=x2;
            2'b11: y=x3; 
            default: y = x0;
        endcase
        
    end

endmodule
