/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none
`include "tt_um_faramire_stopwatch.v"
module stopwatch (
  input wire clk,
  input wire reset_board,
  input wire button_start_stop,
  input wire button_lap_time,
  input wire button_reset,

  output wire mosi,
  output wire cs,
  output wire sck,
  output wire stopwatch_enabled,
  output wire display_enabled
);

  reg [7:0] sink1;

  tt_um_faramire_stopwatch stopwatch1 (
    .ui_in({5'b0, button_reset, button_lap_time, button_start_stop}),
    .uo_out({3'b0, display_enabled, stopwatch_enabled, sck, cs, mosi}),
    .uio_in(8'b0),
    .uio_out(sink1),
    .uio_oe(sink1),
    .ena(1),
    .clk(clk),
    .rst_n(reset_board)
  );
endmodule