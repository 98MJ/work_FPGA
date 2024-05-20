`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/18 11:50:36
// Design Name: 
// Module Name: tb_RX
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


module tb_RX();
    reg clk;
    reg reset;
    reg rx;
    wire [7:0] rx_data;
    wire rx_done;

    UartRx dut(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        reset =  1'b1;
        rx = 1;
    end
    initial begin
        #100 reset = 1'b0; 
        #100 rx = 0;
        #100 rx = 1;
        #100 rx = 0;
        #100 rx = 1;
        #100 rx = 0;
        #100 rx = 1;
        #100 rx = 0;
        #100 rx = 0;
        #100 rx = 1;
        #100 rx = 1;
        
        
        #100;   
    end
endmodule
