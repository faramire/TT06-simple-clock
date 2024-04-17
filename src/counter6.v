/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 ******************************************************
 * Counts up to 6
 */

`define default_netname none

module counter6 (
    input  wire      clk, // clock
    input  wire      ena, // enable
    input  wire      res, // reset, active low
    output reg       max, // high when max value (6) reached
    output reg [2:0] cnt  // 3 bit counter output
 );

    parameter max_count = 6;

    always @(posedge clk or negedge res) begin
        if (!res) begin
            cnt <= 3'b0;
            max <= 1'b0;
        end else if (ena) begin
            if (cnt < (max_count-1)) begin
                cnt <= cnt + 1;
            end else begin
                cnt <= 3'b0;
            end

          if (cnt == max_count-2) begin
            	max <= 1'b1;
            end else begin
                max <= 1'b0;
            end
        end
    end

endmodule