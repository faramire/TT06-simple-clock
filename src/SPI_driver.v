/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module SPI_driver (
    input wire clk,
    input wire [2:0] min_X0, // minutes
    input wire [3:0] min_0X,
    input wire [2:0] sec_X0, // seconds
    input wire [3:0] sec_0X,
    input wire [3:0] ces_X0, // centiseconds (100th)
    input wire [3:0] ces_0X,
    output wire clk_SPI,
    output wire MOSI
 );

endmodule
