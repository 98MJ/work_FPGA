`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/17 10:45:52
// Design Name: 
// Module Name: tb_uart2
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


module tb_uart2();
    reg clk;
    reg reset;
    reg start;
    reg [7:0] tx_data;
    wire txd;
    wire tx_done;       
   
    UART_2 dut(
        .clk(clk),
        .reset(reset),
        .start(start),
        .tx_data(tx_data),
        .tx_done(tx_done),
        .txd(txd)
    );
    always #5 clk = ~clk;
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        start = 1'b0;
        tx_data = 0;
    end
    initial begin
        #100 reset = 1'b0;
        #100 tx_data = 8'b11001010; start = 1'b1;
        #10 start = 1'b0;
    end
    
endmodule
