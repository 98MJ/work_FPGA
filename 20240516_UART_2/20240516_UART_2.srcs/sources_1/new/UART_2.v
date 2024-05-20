`timescale 1ns / 1ps

module uart_TEST(
    input clk,
    input reset,
    input btn_start,
    output txd
);

    wire w_btn_start;

    button U_Button(
        .clk(clk),
        .in(btn_start),
        .out(w_btn_start)
    );
    UART_2 U_TX(
        .clk(clk),
        .reset(reset),
        .start(w_btn_start),
        .tx_data(8'h51),
        .txd(txd)
    );
endmodule

module UART_2(
    input clk, 
    input reset,
    input start,
    input [7:0] tx_data,
    output txd,
    output tx_done
    );

    buadrate_generator U_BR_GEN(
        .clk(clk),
        .reset(reset),
        .br_tick(br_tick)
    );
    transmit U_TXD(
        .clk(clk),
        .start(start),
        .reset(reset),
        .br_tick(br_tick),
        .data(tx_data),
        .txd(txd),
        .tx_done(tx_done)
    );
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

module transmit (
    input clk,
    input reset,
    input start,
    input br_tick,
    input [7:0] data,
    output txd,
    output tx_done
);
    parameter IDLE = 2'b00, START = 2'b01, DATA = 2'b10, STOP = 2'b11;  

    reg [1:0] state, next_state;
    reg tx_reg, tx_next;
    reg tx_done_reg, tx_done_next;
    reg [7:0] tx_data_reg, tx_data_next;
    reg [7:0] r_data;
    //integer i=0, count=0;
    reg [2:0] bit_cnt_reg, bit_cnt_next;
    
    assign txd = tx_reg;
    assign tx_done = tx_done_reg;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= 2'b00;
            tx_reg <= 1'b0;
            bit_cnt_reg <= 2'b00;
            tx_data_reg <= 0;
            tx_done_reg <= 0;
        end else begin
            state <= next_state;
            tx_reg <= tx_next;
            tx_data_reg <= tx_data_next;
            bit_cnt_reg <= bit_cnt_next;
            tx_done_reg <= tx_done_next;
        end
    end

    always @(*) begin
        tx_done_next = tx_done_reg;
        tx_next = tx_reg;
        bit_cnt_next = bit_cnt_reg;
        next_state = state;
        tx_data_next = tx_data_reg;
        case (state)
            IDLE: begin
                tx_next = 1'b1;
                tx_done_next = 1'b0;
                if (start) begin
                    tx_data_next = data;
                    bit_cnt_next = 0;
                    next_state = START;
                end
            end
            START: begin
                tx_next = 1'b0;
                if(br_tick) next_state = DATA;
            end
            DATA: begin
                tx_next = tx_data_reg[0];
                if(br_tick) begin
                    if(bit_cnt_reg == 7)begin
                        //bit_cnt_next = 0; //init at IDLE state
                        next_state = STOP;
                    end else begin
                        bit_cnt_next = bit_cnt_reg + 1;
                        tx_data_next = {1'b0, tx_data_reg[7:1]}; // right shift register
                        //next_state = state;  
                    end              
                end
            end
            STOP: begin
                tx_next = 1'b1;
                if(br_tick)begin
                    next_state = IDLE; 
                    tx_done_next = 1'b1;
                end
            end
       endcase 
    end
endmodule