`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/09 10:31:53
// Design Name: 
// Module Name: Adder
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

module Adder_8bit(
    input [7:0] a,
    input [7:0] b,
    input cin,
    output [7:0] sum,
    output co 
    );

    wire w_carrya;

    Adder U_4ADDER_1(
        .a(a[3:0]),
        .b(b[3:0]),
        .cin(1'b0),
        .sum(sum[3:0]),
        .co(w_carrya)
    );
    Adder U_4ADDER_2(
        .a(a[7:4]),
        .b(b[7:4]),
        .cin(w_carrya),
        .sum(sum[7:4]),
        .co(co)
    );    
endmodule

module Adder (
    input [3:0] a,
    input [3:0] b,
    input cin,
    output [3:0] sum,
    output co
);

  wire [2:0] w_carry;

  fullAdder U_FA0 (
      .a  (a[0]), 
      .b  (b[0]),
      .cin(cin),
      .sum(sum[0]),
      .co (w_carry[0])
  );
  fullAdder U_FA1 (
      .a  (a[1]),
      .b  (b[1]),
      .cin(w_carry[0]),
      .sum(sum[1]),
      .co (w_carry[1])
  );
  fullAdder U_FA2 (
      .a  (a[2]),
      .b  (b[2]),
      .cin(w_carry[1]),
      .sum(sum[2]),
      .co (w_carry[2])
  );
  fullAdder U_FA3 (
      .a  (a[3]),
      .b  (b[3]),
      .cin(w_carry[2]),
      .sum(sum[3]),
      .co (co)
  );
endmodule

module halfAdder (
    input  a,
    input  b,
    output sum,
    output carry
);
  assign sum   = a ^ b;
  assign carry = a & b;

endmodule

module fullAdder (
    input  a,
    input  b,
    input  cin,
    output sum,
    output co
);

  wire w_sum1, w_carry1, w_carry2;

  halfAdder U_HA1 (
      .a(a),
      .b(b),
      .sum(w_sum1),
      .carry(w_carry1)
  );
  halfAdder U_HA2 (
      .a(w_sum1),
      .b(cin),
      .sum(sum),
      .carry(w_carry2)
  );
  assign co = w_carry1 | w_carry2;

endmodule