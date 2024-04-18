/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 */

module SPI_Master (
  input wire clk,
  input wire res,
  input wire cs_in,         // CS input
  input wire [15:0] word_in,   // word to be sent

  output reg sck,           // serial clock
  output reg mosi,          // MOSI
  output reg report_send,   // data has been sent, CS can be pulled high
  output reg report_ready   // ready for next transmission
);

  // FSM states
  localparam IDLE = 2'b00;
  localparam TRANSFER = 2'b01;
  localparam DONE = 2'b10;

  reg  [1:0] state;
  reg  [1:0] count_bit; // count through the clock cylce: negedge, hold high (sample), negedge (set)
  reg  [3:0] count_word; // count through the bits of the word
  reg [15:0] word_out;


  always @(posedge clk or negedge res) begin
    if (!res) begin // async reset, active low
      sck <= 0;
      mosi <= 0;
      count_bit <= 0;
      count_word <= 0;
      word_out <= 16'b0;
      report_send <= 0;
      report_ready <= 0;
      state <= IDLE;
    end else begin
      // FSM
      case(state)

        IDLE: begin
          if (cs_in == 0) begin
            sck <= 0;
            mosi <= 0;
            count_bit <= 0;
            count_word <= 0;
            word_out <= word_in;
            report_send <= 1;
            report_ready <= 1;
            state <= TRANSFER;
          end
        end // IDLE

        TRANSFER: begin
          if (count_word == 0) begin // end of word?
              state <= DONE;
            end

          // send out data on MOSI
          if (count_bit == 0) begin
            mosi <= word_out[count_word];
            /* mosi <= word_out[15]; // or shift out?
            word_out <= word_out << 1; */
            count_word <= count_word - 2'b01;
            
          end

          // generate serial clock
          if (count_bit == 1) begin
            sck <= 1;
          end

          count_bit <= count_bit + 2'b01;
        end // TRANSFER

        DONE: begin
          if (cs_in == 1) begin
            state <= IDLE;
          end
        end // DONE

      endcase
    end
  end

endmodule
