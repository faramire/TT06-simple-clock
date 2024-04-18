/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`include "stopwatch_top_icestick.v"

module ice_stopwatch(
  input CLK_IN,
  input i_board_reset,
  input i_button_start_stop,
  input i_button_lap_time,
  input i_button_reset,

  output wire o_mosi,
  output wire o_cs,
  output wire o_sck,
  output wire o_stopwatch_enabled,
  output wire o_display_enabled

  /* output wire l_mosi,
  output wire l_cs,
  output wire l_sck,
  output wire l_stopwatch_enabled,
  output wire l_display_enabled */
);

  reg [7:0] sink1;

  tt_um_faramire_stopwatch stopwatch1 (
    .ui_in({5'b0, i_button_reset, i_button_lap_time, i_button_start_stop}),
    .uo_out({3'b0, o_display_enabled, o_stopwatch_enabled, o_sck, o_cs, o_mosi}),
    .uio_in(8'b0),
    .uio_out(sink1),
    .uio_oe(sink1),
    .ena(1),
    .clk(CLK_IN),
    .rst_n(i_board_reset)
  );

endmodule // ice_stopwatch