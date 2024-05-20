`timescale 1ns / 1ps

module control_unit(
    input clk, 
    input reset,
    input btn_runStop,
    input btn_clear,
    output run_stop,
    output clear,
    output [2:0] debug_LED
    );

    parameter STOP = 2'd0, RUN = 2'd1, CLEAR = 2'd2;
    reg [1:0] state, state_next;
    reg [2:0] led;
    reg run_stop_reg, run_stop_next, clear_reg, clear_next;

    assign run_stop = run_stop_reg;
    assign clear = clear_next;
    assign debug_LED = led;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= STOP;
            run_stop_reg <= 1'b0;
            clear_reg <= 1'b0;
        end else begin
            state <= state_next;
            clear_reg <= clear_next;
            run_stop_reg <= run_stop_next; 
        end
    end

    always @(*) begin
        state_next = state;
        case (state)
            STOP: begin
                if (btn_runStop) state_next = RUN;
                else if (btn_clear) state_next = CLEAR;
                else state_next = STOP;
            end
            RUN: begin
                if (btn_runStop) state_next = STOP;
                else state_next = RUN;
            end
            CLEAR: begin
                state_next = STOP; 
            end
        endcase
    end

    always @(*) begin
        case (state)
            STOP: begin
                run_stop_next = 1'b0;
                clear_next = 1'b0;
                led = 3'b001;
            end
            RUN : begin
                run_stop_next = 1'b1;
                clear_next = 1'b0;
                led = 3'b010;
            end
            CLEAR: begin
                run_stop_next = 1'b0;
                clear_next = 1'b1;
                led = 3'b100;
            end         
        endcase
    end
endmodule