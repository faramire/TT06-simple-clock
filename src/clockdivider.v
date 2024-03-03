/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 ******************************************************
 * Divides the 1 MHz clock to a 10 Hz clock
 */

`define default_netname none

 module clockDivider (
    input  wire clk_in,
    input  wire res,
    input  wire ena,
    output wire clk_out
 );
    reg[16:0] counter =      0;
    parameter div     = 100000; // 1 MHz / 100'000 = 10 Hz

    always @(posedge clk_in or res) begin
        if (!res) begin     // async reset
            counter <= 0;
            clk_out <= 0;
        end else begin
            if (counter < (div-1)) begin    // count up
                counter <= counter + 1;
            end else begin                  // reset counter and invert output
                counter <= 0;
                clk_out <= ~clk_out;
            end 
        end
    end
 endmodule