/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 ******************************************************
 * Counts up to 6
 */

`define default_netname none

 module counter6 (
    input  wire       clk, // clock
    input  wire       ena, // enable
    input  wire       res, // reset
    output wire       max, // high when max value (6) reached
    output wire [2:0] cnt  // 3 bit counter output
 )

    reg[2:0] counter    = 0;
    parameter max_count = 6;

    always @(posedge clk_in or res) begin
        if (!res) begin     // async reset
            cnt <= 0;
            max <= 0;
        end else if (ena) begin
            if (cnt < max_count - 1) begin
                cnt <= cnt + 1;
            end else begin
                cnt <= 0;
            end
        end
    end

    always @(cnt) begin
        if (cnt == max_count) begin
            max <= 1;
        end else begin
            max <= 0;
        end
    end

 endmodule