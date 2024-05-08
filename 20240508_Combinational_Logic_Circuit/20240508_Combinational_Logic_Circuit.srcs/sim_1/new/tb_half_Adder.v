`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/08 15:32:10
// Design Name: 
// Module Name: tb_half_Adder
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


module tb_half_Adder();

    reg a;
    reg b;
    wire sum;
    wire carry;
    
    half_Adder test_bench(
        .a(a),
        .b(b),
        .sum(sum),
        .carry(carry)
    );
    
    initial begin
        #00 b = 0; a = 0;
        #10 b = 0; a = 1;
        #10 b = 1; a = 0;
        #10 b = 1; a = 1;
        #10 $finish;
    end

endmodule
