/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module counter_chain (
    input wire clk,
    input wire ena,
    input wire res,
    // the X denotes which digit the counter drives
    output reg [3:0] ces_0X, // centiseconds (100th)
    output reg [3:0] ces_X0,
    output reg [3:0] sec_0X, // seconds
    output reg [2:0] sec_X0,
    output reg [3:0] min_0X, // minutes
    output reg [2:0] min_X0
 );

    wire ces_X0_ena;
    wire sec_0X_ena;
    wire sec_X0_ena;
    wire min_0X_ena;
    wire min_X0_ena;

    counter10 inst_ces_0X ( // counts first digit centiseconds
        .clk (clk), // clock in
        .ena (ena), // enable
        .res (res),  // reset
        .max (ces_X0_ena), // reached max value, used as enable for the next counter
        .cnt (ces_0X) // output value
    );

    counter10 inst_ces_X0 ( // counts second digit centiseconds
        .clk (clk),
        .ena (ena & ces_X0_ena),
        .res (res),
        .max (sec_0X_ena),
        .cnt (ces_X0)
    );

    counter10 inst_sec_0X ( // counts first digit seconds
        .clk (clk),
        .ena (ena & ces_X0_ena & sec_0X_ena),
        .res (res),
        .max (sec_X0_ena),
        .cnt (sec_0X)
    );

    counter6 inst_sec_X0 ( // counts second digit seconds
        .clk (clk),
        .ena (ena & ces_X0_ena & sec_0X_ena & sec_X0_ena),
        .res (res),
        .max (min_0X_ena),
        .cnt (sec_X0)
    );

    counter10 inst_min_0X ( // counts single digit minutes
        .clk (clk),
        .ena (ena & ces_X0_ena & sec_0X_ena & sec_X0_ena & min_0X_ena),
        .res (res),
        .max (min_X0_ena),
        .cnt (min_0X)
    );

    counter6 inst_min_X0 ( // counts second digit minutes
        .clk (clk),
        .ena (ena & ces_X0_ena & sec_0X_ena & sec_X0_ena & min_0X_ena & min_X0_ena),
        .res (res),
        .max (),
        .cnt (min_X0)
    );

endmodule