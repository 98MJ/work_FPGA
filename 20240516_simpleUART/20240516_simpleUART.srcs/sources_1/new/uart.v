`timescale 1ns / 1ps

module uart (
    input clk,
    input reset,
    input start,
    input [7:0] tx_data,
    output tx_done,
    output txd
);
    buadrate_generator U_BR_Gen(
        .clk(clk),
        .reset(reset),
        .br_tick(br_tick)
    );

    transmitter U_TxD(
        .clk(clk),
        .start(start), 
        .reset(reset),
        .br_tick(br_tick),
        .data(tx_data),
        .tx_done(tx_done),
        .tx(txd)
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
        if (counter_reg == 100_000_000/9600 - 1) begin
        //if (counter_reg == 10-1)begin
            counter_next = 0;            
            tick_next = 1'b1;
        end
        else begin
            counter_next = counter_reg + 1;
            tick_next = 1'b0;
        end
    end
endmodule

module transmitter(
    input clk,
    input start,
    input reset,
    input [7:0] data,
    input br_tick,
    output tx_done,
    output tx
    );

    localparam  IDLE = 4'd0,
                START = 4'd1, 
                DATA_0 = 4'd2,
                DATA_1 = 4'd3,
                DATA_2 = 4'd4,
                DATA_3 = 4'd5,
                DATA_4 = 4'd6,
                DATA_5 = 4'd7,
                DATA_6 = 4'd8,
                DATA_7 = 4'd9,
                STOP = 4'd10;

    reg [3:0] state, next_state;
    reg tx_reg, tx_next, tx_done_reg, tx_done_next;
    reg [7:0] r_data;
    
    assign tx = tx_reg;
    assign tx_done = tx_done_reg;

    always @(posedge clk) begin
        if(reset) begin
            state <= IDLE;
            tx_reg <= 1'b0;
            tx_done_reg <= 1'b0;
        end
        else begin 
            state <= next_state;
            tx_reg <= tx_next;
            tx_done_reg <= tx_done_next;
        end
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE : if(start) next_state = START;
            START: if(br_tick) next_state = DATA_0;
            DATA_0 :if(br_tick) next_state = DATA_1;
            DATA_1 :if(br_tick)next_state = DATA_2;
            DATA_2 :if(br_tick) next_state = DATA_3;
            DATA_3 :if(br_tick) next_state = DATA_4;
            DATA_4 :if(br_tick) next_state = DATA_5;
            DATA_4 :if(br_tick) next_state = DATA_6;
            DATA_5 :if(br_tick) next_state = DATA_6;
            DATA_6 :if(br_tick) next_state = DATA_7;
            DATA_7 :if(br_tick) next_state = STOP;
            STOP :if(br_tick) next_state = IDLE;
        endcase        
    end

    always @(*) begin
        tx_next = tx_reg;
        tx_done_next = 1'b0;
        //txdata = 0;
        case (state)
            IDLE : tx_next = 1'b1;
            START : begin
                tx_next = 1'b0;
                r_data = data;
            end
            DATA_0 : tx_next= data[0]; 
            DATA_1 : tx_next= data[1];
            DATA_2 : tx_next= data[2];
            DATA_3 : tx_next= data[3];
            DATA_4 : tx_next= data[4];
            DATA_5 : tx_next= data[5];
            DATA_6 : tx_next= data[6];
            DATA_7 : tx_next= data[7];
            STOP : begin
                tx_next = 1'b1;
                if(next_state == IDLE) tx_done_next = 1'b1;
            end
        endcase

        
    end
endmodule
