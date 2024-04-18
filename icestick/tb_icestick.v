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

  wire clk_tt;

  assign reset_either = i_board_reset || i_button_reset;
  wire reset_either; // an OR of the input reset and the chip wide reset, for those that shall be affected by both

  clockDividerIce clockDividerIce1 ( // divides the 12 MHz clock to 1MHz
    .clk_in  (CLK_IN),
    .ena     (1'b1),
    .res     (reset_either),
    .clk_out (clk_tt)
  );

  wire [2:0] sink1;

  tt_um_faramire_stopwatch stopwatch1 (
    .ui_in({5'b00000, i_button_reset, i_button_lap_time, i_button_start_stop}),
    .uo_out({sink1, o_display_enabled, o_stopwatch_enabled, o_sck, o_cs, o_mosi}),
    .uio_in(8'b0),
    .uio_out(),
    .uio_oe(),
    .ena(1'b1),
    .clk(clk_tt),
    .rst_n(i_board_reset)
  );

endmodule // ice_stopwatch

module clockDividerIce (
  input wire clk_in, // input clock 12 MHz
  input wire ena,
  input wire res,    // reset, active low
  output reg clk_out // output clock 1 MHz
);

  reg[2:0] counter;
  parameter div     = 6; // 12 MHz / 12 = 1 MHz, 50% duty cycle => 1/2 of that


  always @(posedge clk_in) begin
    if (!res) begin // reset
      counter <= 3'b0;
      clk_out <= 1'b0;
    end else if (ena) begin
      if (counter < (div-1)) begin    // count up
        counter <= counter + 1;
      end else begin                  // reset counter and invert output
        counter <= 3'b0;
        clk_out <= ~clk_out; 
      end
    end
  end

endmodule //clockDividerIce
