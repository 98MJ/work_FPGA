`timescale 1ns / 1ps
/*
module rx_TEST (
    input clk,
    input reset,
    input btn_start,
    input rx,
    output
);
    
endmodule*/

module UartRx(
    input clk, 
    input reset,
    input rx,
    output [7:0] rx_data,
    output rx_done
    );

    buadrate_generator U_BR_gen(
        .clk(clk),
        .reset(reset),
        .br_tick(br_tick)
    );
    reciever U_RXD(
        .clk(clk), 
        .reset(reset),
        .br_tick(br_tick),
        .rx(rx),
        .o_data(rx_data),
        .rx_done(rx_done)
        );  
endmodule
    
module reciever (
    input clk, 
    input reset,
    input br_tick,
    input rx,
    output [7:0] o_data,
    output rx_done
);
    parameter IDLE = 2'b00, ACK = 2'b01, DATA = 2'b11, STOP = 2'b10;
    reg [1:0] state, next_state;
    reg [7:0] r_data;
    reg [7:0] rx_data_reg, rx_data_next;
    reg rx_reg, rx_next;
    reg [2:0] cnt_reg, cnt_next;
    reg rx_done_reg, rx_done_next;

    assign o_data = r_data;
    assign rx_done = rx_done_reg;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= 2'b00;
            cnt_reg <= 0;
            rx_done_reg <= 0;
            rx_reg <= 0;
            rx_data_reg <= 0;
        end
        else begin
            state <= next_state;
            cnt_reg <= cnt_next;
            rx_done_reg <= rx_done_next;
            rx_reg <= rx_next;
            rx_data_reg <=rx_data_next;
        end
    end

    always @(*) begin
        next_state = state;
        rx_done_next = rx_done_reg;
        cnt_next = cnt_reg;
        rx_data_next = rx_data_reg;
        rx_reg <= rx_next;
        case (state)
            IDLE: begin
                rx_done_next = 1'b0;
                if((rx == 1'b0)&&br_tick) begin
                    next_state = ACK;
                end
            end
            ACK: begin
                if (br_tick) begin
                    next_state = DATA;
                    rx_data_next[0] = rx;
                end
            end
            DATA: begin
                if(br_tick) begin
                    if(cnt_reg == 7) begin
                        next_state = STOP;
                        cnt_next= 0;
                    end else begin
                        rx_data_next[cnt_next+1] = rx;
                        cnt_next = cnt_reg + 1;
                        next_state = DATA;
                    end
                end
            end
            STOP: begin
                if (br_tick) begin
                    next_state = IDLE;
                    rx_done_next = 1'b1;
                    r_data = rx_data_reg;
                end
            end
        endcase
    end
   

endmodule


module buadrate_generator (
    input clk, 
    input reset,
    output br_tick
);
    reg [$clog2(100_000_000 / 9600)-1:0] counter_reg, counter_next;
    reg tick_next, tick_reg;

    assign br_tick = tick_reg;

    always @(posedge clk, posedge reset ) begin
        if(reset) begin
            counter_reg <= 0;
            tick_reg <= 1'b0;
        end
        else begin
            counter_reg <= counter_next;
            tick_reg <= tick_next;
        end 
    end

    always @(*) begin
        //if (counter_reg == 100_000_000/9600 - 1) begin
        if (counter_reg == 10-1)begin
            counter_next = 0;            
            tick_next = 1'b1;
        end
        else begin
            counter_next = counter_reg + 1;
            tick_next = 1'b0;
        end
    end
endmodule