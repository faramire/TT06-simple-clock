/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module controller (
    input  wire res,            // reset, active low
    input  wire start_stop,     // impulse toggles counter_enable
    input  wire lap_time,       // impulse toggles display_enable
    output reg  counter_enable, // 
    output reg  display_enable  //
 );
  
    always @(posedge start_stop or negedge res) begin
        if (!res)
            counter_enable <= 0;
        else
            counter_enable <= ~counter_enable;
    end
  
    always @(posedge lap_time or negedge res) begin
        if (!res)
            display_enable <= 1;
        else
            display_enable <= ~display_enable;
    end
  
endmodule