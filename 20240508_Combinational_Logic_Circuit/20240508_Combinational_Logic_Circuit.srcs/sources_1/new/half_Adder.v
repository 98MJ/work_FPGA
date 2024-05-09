`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/08 15:23:23
// Design Name: 
// Module Name: half_Adder
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

module _4bit_FullAdder(
    input a0,
    input a1,
    input a2,
    input a3,
    input b0,
    input b1,
    input b2,
    input b3,
    input cin,
    output sum0,
    output sum1,
    output sum2,
    output sum3,
    output carry
);

wire w_fcarry1, w_fcarry2, w_fcarry3, w_fcarry4;
    
full_Adder u_FA1(
    .a(a0),
    .b(b0),
    .cin(cin),
    .sum(sum0),
    .carry(w_fcarry1)
);
full_Adder u_FA2(
    .a(a1),
    .b(b1),
    .cin(w_fcarry1),
    .sum(sum1),
    .carry(w_fcarry2)
);
full_Adder u_FA3(
    .a(a2),
    .b(b2),
    .cin(w_fcarry2),
    .sum(sum2),
    .carry(w_fcarry3)
);
full_Adder u_FA4(
    .a(a3),
    .b(b3),
    .cin(w_fcarry3),
    .sum(sum3),
    .carry(carry)
);
endmodule


module full_Adder (
    input a,
    input b,
    input cin,
    output sum,
    output carry
);
    wire w_sum1, w_carry1, w_carry2;

half_Adder u_HA1(
    .a(a),
    .b(b),
    .sum(w_sum1),
    .carry(w_carry1)
    );
    
half_Adder u_HA2(
    .a(w_sum1),
    .b(cin),
    .sum(sum),
    .carry(w_carry2)
    );
    
    assign carry = w_carry1 | w_carry2;
    
endmodule

module half_Adder(
    input a, 
    input b,
    output sum,
    output carry
    );
    
    assign sum = a ^ b;
    assign carry = a & b;
    
endmodule