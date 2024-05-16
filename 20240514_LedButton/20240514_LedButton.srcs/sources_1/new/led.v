`timescale 1ns / 1ps

module led_toggle (
    input clk,
    input reset,
    input btnC,
    output led
);

wire w_button;


button U_Btn(
    .clk(clk),
    .in(btnC),
    .out(w_button)
);
led_fsm U_FSM(
    .clk(clk),
    .reset(reset),
    .btnC(w_button),
    .led(led)
);
endmodule

module led_fsm(
    input reset,
    input btnC,
    input clk,
    output reg led
);

    parameter LED_OFF = 1'b0;
    parameter LED_ON = 1'b1;

    reg state,state_next;

    // state register (현재tk)
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= LED_OFF;
        end else begin
            state <= state_next;
        end
    end

    // nextState register
    always @(state, btnC) begin
        state_next = state;
        case (state)
            LED_OFF: begin
                if(btnC == 1'b1) state_next = LED_ON;
                else state_next = state;
            end
            LED_ON : begin
                if(btnC == 1'b1) state_next = LED_OFF;
                else state_next = state;
            end             
        endcase
    end

    //output combinational logic circuit
    //moore machine
    always @(state) begin
        led = 1'b0;
        case (state)
            LED_OFF: led = 1'b0;
            LED_ON : led = 1'b1;
                
        endcase
    end
    
    //output combinational logic circuit
    //mealy machine
    /*always @(state, btnC) begin
        led = 1'b0;
        case (state)
            LED_OFF: begin
                if(btnC == 1'b1) led = 1'b1;
                else led = 1'b0;
            end
            
            LED_ON : begin
                if(btnC == 1'b1) led = 1'b0;
                else led = 1'b1;
            end
                
        endcase
    end*/

endmodule
