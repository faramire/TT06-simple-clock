/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none
`include "clockdivider.v"
`include "controller.v"
`include "counter6.v"
`include "counter10.v"
`include "counter_chain.v"
`include "SPI_wrapper.v"
`include "SPI_Master_With_single_CS.v"
//`include "SPI_driver.v"

// ui_in [0]: reset: resets the stopwatch to 00:00:00
// ui_in [1]: speed: 

module tt_um_faramire_stopwatch (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
 );
  // All output pins must be assigned. If not used, assign to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  wire dividedClock; // 100 Hz clock
  wire counter_enable;
  wire display_enable;
  wire reset_either; // an OR of the input reset and the chip wide reset, for those that shall be affected by both
  wire clock_enable; // and AND of the clock with the counter enable,
                     // so that the clock divider doesn't advance when the counters are halted

  assign reset_either = rst_n | (~ui_in[2]);
  assign clock_enable = counter_enable & clk;

  wire [2:0] min_X0; // all the results of the counter chain
  wire [3:0] min_0X;
  wire [2:0] sec_X0;
  wire [3:0] sec_0X;
  wire [3:0] ces_X0;
  wire [3:0] ces_0X;

  clockDivider clockDivider1 ( // divides the 100 MHz clock to 100 Hz
    .clk_in  (clock_enable),
    .res     (reset_either),
    .clk_out (dividedClock)
  );

  controller controller1 ( // two latches for starting/stopping and lap times
    .res        (rst_n),
    .start_stop (ui_in[0]),
    .lap_time   (ui_in[1]),
    .counter_enable (counter_enable),
    .display_enable (display_enable)
  );

  assign uo_out[3] = counter_enable; // output the internal state
  assign uo_out[4] = display_enable;

  counter_chain counter_chain1 ( // a chain of 6 counters that count from 00:00:00 to 59:59:99
    .clk (dividedClock),
    .ena (counter_enable),
    .res (reset_either),
    .min_X0 (min_X0),
    .min_0X (min_0X),
    .sec_X0 (sec_X0),
    .sec_0X (sec_0X),
    .ces_X0 (ces_X0),
    .ces_0X (ces_0X)
  );

  SPI_wrapper SPI_wrapper1 (
    .clk (clk),
    .res (rst_n),
    .ena (display_enable),
    .clk_div(dividedClock),
    .min_X0 (min_X0),
    .min_0X (min_0X),
    .sec_X0 (sec_X0),
    .sec_0X (sec_0X),
    .ces_X0 (ces_X0),
    .ces_0X (ces_0X),
    .MOSI    (uo_out[0]), // MOSI on out 0
    .CS      (uo_out[1]), //  CS  on out 1
    .clk_SPI (uo_out[2])  //  CLK on out 3
  );

  /* SPI_driver SPI_driver1 ( // drives the 7-segment displays connected via a MAX7219 chip over SPI
    .clk (clk),
    .res (rst_n),
    .ena (display_enable),
    .clk_div(dividedClock),
    .min_X0 (min_X0),
    .min_0X (min_0X),
    .sec_X0 (sec_X0),
    .sec_0X (sec_0X),
    .ces_X0 (ces_X0),
    .ces_0X (ces_0X),
    .MOSI    (uo_out[0]), // MOSI on out 0
    .CS      (uo_out[1]), //  CS  on out 1
    .clk_SPI (uo_out[2])  //  CLK on out 3
  ); */

endmodule