/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 ******************************************************
 * Divides the 1 MHz clock to a 100 Hz clock, 10ms per step
 */

`define default_netname none

module clockDivider (
    input wire clk_in, // input clock 1 MHz
    input wire res,    // async reset, active low
    output reg clk_out // output clock 100 Hz
 );

    reg[13:0] counter;
    parameter div     = 5000; // 1 MHz / 10'000 = 100 Hz, 50% duty cycle => 1/2 of that


    always @(posedge clk_in or negedge res) begin
        if (!res) begin     // async reset
            counter <= 14'b0;
            clk_out <= 1'b0;
        end else if (counter < (div-1)) begin    // count up
            counter <= counter + 1;
        end else begin                  // reset counter and invert output
            counter <= 1'b0;
            clk_out <= ~clk_out; 
        end
    end

endmodule