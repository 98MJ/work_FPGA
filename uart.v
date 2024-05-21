`timescale 1ns / 1ps

module top_tx_rx_loop(
    input clk, 
    input reset,
    output tx,
    input rx
);
    wire [7:0] w_rx_data;
    wire w_rx_done;

    uart U_UART(
        .clk(clk),
        .reset(reset),
        .tx(tx),
        .start(w_rx_done),
        .tx_data(w_rx_data),
        .rx(rx),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)
    );

endmodule

module uart(
    input clk,
    input reset,
    //tr
    input start,
    input [7:0] tx_data,
    output tx,
    output tx_done,
    //re    
    input rx,
    output [7:0] rx_data,
    output rx_done
    );
    
    baudrate_generator U_BAUDRATE_GEN(
        .clk(clk),
        .reset(reset),
        .br_tick(w_br_tick)
    );
    tr U_Transmitter(
        .clk(clk),
        .reset(reset),
        .br_tick(w_br_tick),
        .start(start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_done(tx_done)
    );
    re U_Receiver(
        .clk(clk),
        .reset(reset),
        .br_tick(w_br_tick),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );
endmodule

module baudrate_generator (
    input clk,
    input reset,
    output br_tick
);
    reg tick_reg, tick_next;
    reg [$clog2(100_000_000 / 9600 / 16) - 1 : 0] counter_reg, counter_next;
    assign br_tick = tick_reg;

    always @(posedge clk, posedge reset) begin
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
        counter_next = counter_reg;
        if (counter_reg == 100_000_000 / 9600 / 16- 1) begin
        //if (counter_reg == 3) begin
            counter_next = 0;
            tick_next = 1'b1;
        end
        else begin
            counter_next = counter_reg + 1;
            tick_next = 1'b0;
        end
    end
endmodule

module tr (
    input clk,
    input reset,
    input start,
    input [7:0] tx_data,
    input br_tick,
    output tx,
    output tx_done
);

    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;
    reg [1:0] state, state_next;
    reg tx_reg, tx_next;
    reg tx_done_reg, tx_done_next;
    reg [7:0] data_tmp_next, data_tmp_reg;
    reg [3:0] br_cnt_next, br_cnt_reg;
    reg [2:0] data_bit_cnt_next, data_bit_cnt_reg;

    assign tx = tx_reg;
    assign tx_done = tx_done_reg;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= IDLE;
            tx_reg <= 1'b0;
            tx_done_reg <= 1'b0;
            br_cnt_reg <= 0;
            data_bit_cnt_reg <= 0;
            data_tmp_reg <= 0;
        end else begin
            state <= state_next;
            tx_reg <= tx_next;
            tx_done_reg <= tx_done_next;
            br_cnt_reg <= br_cnt_next;
            data_bit_cnt_reg <= data_bit_cnt_next;
            data_tmp_reg <= data_tmp_next;
        end
    end

    always @(*) begin
        // latch prevention
        state_next = state;
        data_tmp_next = data_tmp_reg;
        tx_next = tx_reg;
        br_cnt_next = br_cnt_reg;
        tx_done_next = tx_done_reg;
        data_bit_cnt_next = data_bit_cnt_reg;
        case (state)
            IDLE: begin
                tx_done_next = 1'b0;
                tx_next = 1'b1;
                if (start) begin
                    state_next = START;
                    data_tmp_next = tx_data;
                    br_cnt_next = 0;
                    data_bit_cnt_next = 0;
                end
            end
            START: begin
                tx_next = 1'b0;
                if(br_tick) begin
                    if(br_cnt_reg == 15)begin
                        state_next = DATA;
                        br_cnt_next = 0;
                    end else begin
                        br_cnt_next = br_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                tx_next = data_tmp_reg[0];
                if(br_tick) begin
                    if(br_cnt_reg == 15) begin
                        if(data_bit_cnt_reg == 7) begin
                            state_next = STOP;
                            br_cnt_next = 0;
                        end else begin
                            data_bit_cnt_next = data_bit_cnt_reg + 1;
                            data_tmp_next = {1'b0, data_tmp_reg[7:1]};
                            br_cnt_next = 0;
                        end
                    end else begin
                        br_cnt_next = br_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                tx_next = 1'b1;
                if (br_tick) begin
                    if(br_cnt_reg == 15) begin
                        tx_done_next = 1'b1;
                        state_next = IDLE;
                    end else begin
                        br_cnt_next = br_cnt_reg + 1;
                    end
                end
            end
        endcase
    end
endmodule

module re (
    input clk,
    input reset,
    input br_tick,
    input rx,
    output [7:0] rx_data,
    output rx_done
);
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;

    reg [1:0] state, state_next;
    reg [7:0] rx_data_reg, rx_data_next;
    reg rx_done_reg, rx_done_next;
    reg [4:0] br_cnt_next, br_cnt_reg;
    reg [2:0] data_bit_cnt_next, data_bit_cnt_reg;

    assign rx_data = rx_data_reg;
    assign rx_done = rx_done_reg;
    
    always @(posedge clk , posedge reset) begin
        if (reset) begin
            state <= IDLE;
            rx_data_reg <= 0;
            rx_done_reg <= 1'b0;
            br_cnt_reg <= 0;
            data_bit_cnt_reg <= 0;
        end
        else begin
            state <= state_next;
            rx_data_reg <= rx_data_next;
            rx_done_reg <= rx_done_next;
            br_cnt_reg <= br_cnt_next;
            data_bit_cnt_reg <= data_bit_cnt_next;
        end
    end
    always @(*) begin
        state_next = state;
        br_cnt_next = br_cnt_reg;
        data_bit_cnt_next = data_bit_cnt_reg;
        rx_data_next = rx_data_reg;
        rx_done_next = rx_done_reg;
        case (state)
            IDLE: begin
                rx_done_next = 1'b0;
                if(rx == 1'b0) begin
                    br_cnt_next = 0;
                    data_bit_cnt_next = 0;
                    rx_data_next = 0;                    
                    state_next = START;
                end
            end
            START: begin
                if (br_tick) begin
                    if (br_cnt_reg == 7) begin
                        br_cnt_next = 0;
                        state_next = DATA;
                    end else begin
                        br_cnt_next = br_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                if(br_tick) begin
                    if(br_cnt_reg == 15) begin
                        br_cnt_next = 0;
                        rx_data_next = {rx, rx_data_reg[7:1]};
                        if(data_bit_cnt_reg == 7)begin
                            data_bit_cnt_next = 0;
                            state_next = STOP;
                        end else begin
                            data_bit_cnt_next = data_bit_cnt_reg + 1;
                        end
                    end else begin
                        br_cnt_next = br_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                if (br_tick) begin
                    if (br_cnt_reg == 23) begin
                        br_cnt_next = 0;
                        state_next = IDLE;
                        rx_done_next = 1'b1;
                    end else begin
                        br_cnt_next = br_cnt_reg + 1;
                    end
                end
            end
        endcase
    end
endmodule