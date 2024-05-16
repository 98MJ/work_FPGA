`timescale 1ns / 1ps

module test(
    input [2:0] a,
    output out_nor3
    );
    assign out_nor3 = ~(a[2] | a[1] | a[0]);
        


endmodule

module nor3_redop (
    input [2:0] a,
    output out_nor3

);
    assign out_nor3 = ~|a;
endmodule

module nor3_gp (
    input [2:0] a
);
    nor (out_nor3, a[2], a[1], a[0]);
endmodule

module nor3_if (
    input [2:0] a,
    output out_nor3
);
    reg out_nor3;

    always @(a) begin
        if(a==3'b000) out_nor3 = 1'b1;
        else          out_nor3 = 1'b0;
    end 
endmodule

module xor4b_gp (
    input [3:0] a,
    input [3:0] b,
    output [3:0] xor4b
);
    xor U0 [3:0] (xor4b, a, b);
endmodule

module xor4b_bitop (
    input [3:0] a,
    input [3:0] b,
    output [3:0] xor4b
);
  assign xor4b = a^b;  
endmodule

module xor4b_for (
    input [3:0] a,
    input [3:0] b,
    output [3:0] xor4b
);
    reg [3:0] xor4b;
    integer i;
    
    always @(a or b) begin
        for (i = 0; i<4; i=i+1) begin
            xor4b[i] = a[i] ^ b[i];
        end
    end
endmodule

module bin2gray (
    input [3:0] bin,
    output [3:0] gray
);
    reg [3:0] gray;

    always @(bin) begin
        case (bin)
            4'h0 : gray = 4'b0000;
            4'h1 : gray = 4'b0001;
            4'h2 : gray = 4'b0011;
            4'h3 : gray = 4'b0010;
            4'h4 : gray = 4'b0110;
            4'h5 : gray = 4'b0111;
            4'h6 : gray = 4'b0110;
            4'h7 : gray = 4'b0111;
            4'h8 : gray = 4'b1000;
            4'h9 : gray = 4'b1001;
            4'ha : gray = 4'b1010;
            4'hb : gray = 4'b1011;
            4'hc : gray = 4'b1100;
            4'hd : gray = 4'b1101;
            4'he : gray = 4'b1110;
            4'hf : gray = 4'b1111;
            default: 
        endcase
    end
    
endmodule

module mux4to1_conop (
    input [3:0] a,
    input [3:0] b,
    input [3:0] c,
    input [3:0] d,
    input [1:0] sel,
    output [3:0] mux_out
);
    reg [3:0] mux_out;

    always @(sel or a or b or c or d) begin
        if      (sel == 2'b'00) mux_out = a;
        else if (sel == 2'b'01) mux_out = b;
        else if (sel == 2'b'10) mux_out = c;
        else if (sel == 2'b'11) mux_out = d;
        else                    mux_out = 4'bx;
    end
endmodule