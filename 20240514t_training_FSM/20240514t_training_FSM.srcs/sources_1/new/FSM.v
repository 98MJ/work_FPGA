`timescale 1ns / 1ps

module FSM(
    input clk,
    input rstn,
    input go,
    input ws,
    output rd,
    output ds
    );
    parameter IDLE = 2'b00;
    parameter READ = 2'b01;
    parameter DLY  = 2'b10;
    parameter DONE = 2'b11;

    reg [1:0] state, next;

    // state
    always @(posedge clk, negedge rstn) begin
        if(!rstn) state <= IDLE;
        else      state <= next;
    end

    // next
    always @(state or go or ws) begin
        next = 2'bx;
        case (state)
           IDLE : if(go) next = READ;
                    else next = IDLE;
           READ :        next = DLY;
           DLY  : if(!ws) next = DONE;
                    else next = READ;
           DONE :        next = IDLE;
        endcase
    end

    // output
    assign rd = ((state == READ) || (state === DLY));
    assign ds = (state == DONE);
endmodule


