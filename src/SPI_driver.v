/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module SPI_driver (
    input wire clk,
    input wire clk_div,
    input wire res,
    input wire ena,
    input wire [2:0] min_X0, // minutes
    input wire [3:0] min_0X,
    input wire [2:0] sec_X0, // seconds
    input wire [3:0] sec_0X,
    input wire [3:0] ces_X0, // centiseconds (100th)
    input wire [3:0] ces_0X,
    output wire MOSI,
    output wire CS,
    output wire clk_SPI
 );

    reg [1:0] state; // FSM
    localparam Reset = 2'b00;
    localparam Init  = 2'b01;
    localparam Idle  = 2'b10;
    localparam Send  = 2'b11;

    wire send_order; // goes high to order a send 
    wire [15:0] data_send; // SPI data to be send, [11:8] is address, [7:0] is data
    wire done_order; // goes high to signal end of send

    reg [3:0] bit_send; // counts through bits
    reg [2:0] digit; // counts through digits to be send

    always @(posedge clk_div or negedge res) begin
        if (!res) begin
            state <= Reset;
        end else begin
            Case(state)
                Reset: begin
                    send_order <= 0;
                    done_order <= 0;
                    bit_send <= 0;
                    digit <= 0;
                    CS <= 1;
                    MOSI <= 0;
                    clk_SPI <= 0;
                    if (res) begin
                        state <= Init;
                    end
                end
                
                Init: begin

                    state <= Idle;
                end

                Idle: begin
                    if (ena) begin
                        state <= Send;
                    end
                end

                Send: begin
                    if (!ena) begin
                        state <= Idle;
                    end else begin

                    end
                end
                default:;
            endcase
        end    
    end

    always @(posedge send_order) begin
        CS <= 0;
    end

endmodule
