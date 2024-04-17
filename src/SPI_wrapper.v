/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 */

module SPI_wrapper (
    input wire clk, // 1 MHz clock to run the FSM and other loops
    input wire clk_div, // 100 Hz clock to trigger a time to be send out
    input wire res, // reset, active low
    input wire ena,

    input wire [2:0] min_X0, // minutes
    input wire [3:0] min_0X,
    input wire [2:0] sec_X0, // seconds
    input wire [3:0] sec_0X,
    input wire [3:0] ces_X0, // centiseconds (100th)
    input wire [3:0] ces_0X,

    output reg MOSI,
    output reg CS,
    output reg clk_SPI
);

// FSM
    reg [1:0] state;
    localparam Reset = 2'b00;
    localparam Init  = 2'b01;
    localparam Time  = 2'b10;

    always @(posedge clk_div or negedge res) begin  // FSM
        if (!res) begin // active low reset
            state <= Reset;
        end
        Case(state)
            Reset: begin
                send_time <= 1'b0;
                send_init <= 1'b0;
                init_reset <= 1'b1;
                if (res) begin // once res goes high again: switch to Init
                    state <= Init;
                    init_reset <= 1'b0;
                end
            end
            
            Init: begin
                send_init <= 1'b1;
                if (init_complete) begin
                    send_init <= 1'b0;
                    state <= Time;
                end
            end

            Time: begin
                send_time <= 1'b1;
            end

            default:;
        endcase    
    end




    SPI_Master_With_Single_CS SPI_Master1 (
        .i_Rst_L(res)
        .i_Clk(clk)
    );

endmodule