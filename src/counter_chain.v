/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module counter_chain (
    input wire clk,
    output wire [2:0] min_X0, // minutes
    output wire [3:0] min_0X,
    output wire [2:0] sec_X0, // seconds
    output wire [3:0] sec_0X,
    output wire [3:0] ces_X0, // centiseconds (100th)
    output wire [3:0] ces_0X
 );


endmodule