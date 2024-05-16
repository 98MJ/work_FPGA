`timescale 1ns / 1ps

module StopWatch (
    input clk,
    input reset,
    input btn1,
    input btn2,
    output [7:0] fndFont,
    output [3:0] fndCom
);

//    wire w_clk_10hz;
    wire enData, clearData;
    wire [13:0] counterData;
    wire w_buttonRst, w_buttonRun, w_buttonClear;

    StopWatch_FSM U_StopWatch(
        .clk(clk),
        .reset(w_buttonRst),
        .btn_R(w_buttonRun),
        .btn_C(w_buttonClear),
        .clear(clearData),
        .en(enData)
    );
    button U_BtnReset(
        .clk(clk),
        .in(reset),
        .out(w_buttonRst)
    );
    button U_BtnRun(
        .clk(clk),
        .in(btn1),
        .out(w_buttonRun)
    );
    button U_BtnClear(
        .clk(clk),
        .in(btn2),
        .out(w_buttonClear)
    );
    /*
    clkDiv_FSM #(.HERZ(10)) U_CLK(
        .clk(clk),
        .reset(w_buttonRst),
        .o_clk(w_clk_10hz)
    );
    Counter_FSM #(.MAX_NUM(10000)) U_COUNTER_10000(
        .clk(clk),
        .reset(w_buttonRst),
        .clearIn(clearData),
        .tick(w_clk_10hz),
        .en(enData),
        .counter(counterData)
    );*/
    Counter_100ms9999 U_9999(
        .clk(clk),
        .reset(w_buttonRst),
        .clearIn(clearData),
        .en(enData),
        .counter(counterData)
    );
    
    fndController U_FND(
        .reset(w_buttonRst),
        .clk(clk),
        .digit(counterData),
        .fndFont(fndFont),
        .fndCom(fndCom)
    );

    
endmodule

module Counter_100ms9999 (
    input clk,
    input reset,
    input clearIn,
    input en,
    output [13:0] counter
);

    wire w_clk_10hz;

    clkDiv_FSM #(.HERZ(10)) U_CLK(
        .clk(clk),
        .reset(reset),
        .o_clk(w_clk_10hz)
    );
    Counter_FSM #(.MAX_NUM(10000)) U_COUNTER_10000(
        .clk(clk),
        .reset(reset),
        .clearIn(clearIn),
        .tick(w_clk_10hz),
        .en(en),
        .counter(counter)
    );
    
endmodule

module StopWatch_FSM (
    input clk,
    input reset,
    input btn_R,
    input btn_C,
    output reg clear,
    output reg en
);
    parameter STOP = 2'b00;
    parameter RUN = 2'b01;
    parameter CLEAR = 2'b10;

    reg [1:0] state, next;

    always @(posedge clk, posedge reset) begin
        if(reset) state <= STOP;
        else      state <= next;        
    end

    always @(*) begin
        next = 2'bx;
        case (state)
            STOP : begin
                if(btn_R == 1'b1) next = RUN;
                else if(btn_C == 1'b1) next = CLEAR;
                else next = state;
            end 
            RUN : begin
                if(btn_R == 1'b1) next = STOP;
                else next= state;
            end
            CLEAR : next = STOP;
        endcase
    end
    
    always @(state) begin
        clear = 1'b0;
        en = 1'b0;
        case (state)
            STOP: begin
                clear = 1'b0;
                en = 1'b0;
            end 
            RUN : begin
                clear = 1'b0;
                en = 1'b1;
            end
            CLEAR: begin
                clear = 1'b1;
                en = 1'b0;
            end
        endcase
    end

endmodule

module clkDiv_FSM #(
    parameter HERZ = 100
) (
    input clk,
    input reset,
    output o_clk
);
    reg [$clog2(100_000_000/HERZ)-1 : 0] counter;
    reg r_clk;

    assign o_clk = r_clk;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
        end
        else begin
            if (counter == (100_000_000/HERZ-1)) begin
                counter <= 0;
                r_clk <= 1'b1;                
            end else begin
                counter <= counter + 1;
                r_clk <= 1'b0;
            end
        end
    end
    
endmodule

module Counter_FSM#(parameter MAX_NUM = 10000)(
    input clk, // system operation clock
    input reset, 
    input clearIn,
    input tick, // time clock ex) 100hz(0.01sec)
    input en,
    output [$clog2(MAX_NUM)-1:0] counter
    );
    reg [$clog2(MAX_NUM)-1:0] counter_reg, counter_next;

    //state register
    always @(posedge clk, posedge reset, posedge clearIn) begin
        if (reset) begin
            counter_reg <= 0;
        end 
        else if (clearIn) begin
            counter_reg <= 0;
        end
        else begin
            counter_reg <= counter_next;
        end
    end

    //next state CL
    always @(*) begin
       if(tick & en) begin
            if (counter_reg == MAX_NUM - 1) begin
                counter_next = 0;
            end
            else begin
                counter_next = counter_reg + 1;
            end
       end else begin
            counter_next = counter_reg;
       end
    end

    //output CL
    assign counter = counter_reg;
endmodule
