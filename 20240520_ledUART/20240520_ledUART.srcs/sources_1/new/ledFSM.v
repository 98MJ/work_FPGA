`timescale 1ns / 1ps

module uart_led (
    input clk,
    input reset,
    input rx,
    output [2:0] led
);
    wire [7:0] w_led_data;

    uart U_uart(
        .clk(clk),
        .reset(reset),
        .start(),
        .tx_data(),
        .tx(),
        .tx_done(),
        //re    
        .rx(rx),
        .rx_data(w_led_data),
        .rx_done()
    );

    ledFSM U_ledController(
        .clk(clk),
        .reset(reset),
        .data(w_led_data),
        .led(led)
    );
    
endmodule

module ledFSM(
    input clk,
    input reset,
    input [7:0] data,
    output [2:0] led
    );

    localparam NONE = 0, LED_1 = 1, LED_2 = 3, LED_3 = 2;
    
    reg [1:0] state, state_next;
    reg [7:0] led_reg, led_next;
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 1'b0;
            led_reg <= 0;
        end else begin
            state <= state_next;
            led_reg <= led_next;
        end
    end

    always @(*) begin
        state_next = state;
        case (state)
            NONE: begin
                led_next = 3'b000;
                if (data == 8'h31) begin
                    state_next = LED_1;
                end
                else if (data == 8'h32) begin
                    state_next = LED_2;
                end
                else if (data == 8'h33) begin
                    state_next = LED_3;
                end else begin
                    state_next = NONE;
                end   
            end 
            LED_1: begin
                led_next = 3'b001;
                if (data == 8'h32) begin
                    state_next = LED_2;
                end
                else if (data == 8'h33) begin
                    state_next = LED_3;
                end
                else if (data == 8'h30) begin
                    led_next = NONE;
                end else begin
                    state_next = LED_1;
                end   
            end 
            LED_2: begin
                led_next = 3'b011;
                if (data == 8'h33) begin
                    state_next = LED_3;
                end
                else if (data == 8'h31) begin
                    state_next = LED_1;
                end
                else if (data == 8'h30) begin
                    led_next = NONE;
                end else begin
                    state_next = LED_2;
                end   
            end  
            LED_3: begin
                led_next = 3'b111;
                if (data == 8'h31) begin
                    state_next = LED_1;
                end
                else if (data == 8'h32) begin
                    state_next = LED_2;
                end
                else if (data == 8'h30) begin
                    led_next = NONE;
                end else begin
                    state_next = LED_3;
                end   
            end 
        endcase
    end

    assign led = led_reg;

endmodule
