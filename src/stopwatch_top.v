/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

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

  wire [2:0] min_X0; // all the results of the counter chain
  wire [3:0] min_0X;
  wire [2:0] sec_X0;
  wire [3:0] sec_0X;
  wire [3:0] ces_X0;
  wire [3:0] ces_0X;

  clockDivider inst1 ( // divides the 100 MHz clock to 100 Hz
    .clk_in  (clk),
    .res     (rst_n),
    .clk_out (dividedClock)
  );

  controller inst1 ( // two latches for starting/stopping and lap times
    .res        (rst_n),
    .start_stop (ui_in[0]),
    .lap_time   (ui_in[1]),
    .counter_enable (counter_enable),
    .display_enable (display_enable)
  );

  assign uo_out[3] = counter_enable; // output the internal state
  assign uo_out[4] = display_enable;

  counter_chain inst1 ( // a chain of 6 counters that count from 00:00:00 to 59:59:99
    .clk (dividedClock),
    .ena (counter_enable),
    .res (rst_n),
    .min_X0 (min_X0)
    .min_0X (min_0X),
    .sec_X0 (sec_X0),
    .sec_0X (sec_0X),
    .ces_X0 (ces_X0),
    .ces_0X (ces_0X)
  );

  SPI_driver inst1 ( // drives the 7-segment displays connected via a MAX7219 chip over SPI
    .clk (clk),
    .res (res),
    .ena (display_enable),
    .min_X0 (min_X0)
    .min_0X (min_0X),
    .sec_X0 (sec_X0),
    .sec_0X (sec_0X),
    .ces_X0 (ces_X0),
    .ces_0X (ces_0X),
    .MOSI    (uo_out[0]),
    .CS      (uo_out[1]),
    .clk_SPI (uo_out[2])
  );

endmodule
