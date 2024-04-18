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
  localparam IDLE     = 2'b00;
  localparam TRANSFER = 2'b01;
  localparam DONE     = 2'b10;

  reg  [1:0] state;
  reg  [1:0] count_bit; // count through the clock cylce: 00 pull low (set), 01 hold low, 10 pull high (sample), 11 hold high
  reg  [3:0] count_word; // count through the bits of the word
  reg        word_done;
  reg [15:0] word_out;


  always @(posedge clk) begin
    if (!res) begin // async reset, active low
      sck <= 0;
      mosi <= 0;
      report_send <= 0; // goes high when all data has been send and CS is still low
      report_ready <= 0; // goes high when CS is high and reset is complete
      state <= IDLE;
    end else begin

      case(state) // FSM

        IDLE: begin
          if (cs_in == 1) begin
            report_send <= 0;
            report_ready <= 1;
          end
          if (cs_in == 0) begin // order to send the word
            count_bit <= 0;
            count_word <= 15;
            word_done <= 0;
            word_out <= word_in;
            report_send <= 0;
            report_ready <= 0;
            state <= TRANSFER;
          end
        end // IDLE

        TRANSFER: begin
          case(count_bit)

            2'b00: begin // pull low
              sck <= 1'b0;
              count_bit <= 2'b01;

              mosi <= word_out[15];
              word_out <= word_out << 1;

              // alternative:
              /* mosi <= word_out[count_word];
              count_word <= count_word - 1; */
            end

            2'b01: begin // hold low
              sck <= 1'b0;
              count_bit <= 2'b10;
            end

            2'b10: begin // pull high
              sck <= 1'b1;
              count_bit <= 2'b11;
            end

            2'b11: begin // hold high
              sck <= 1'b1;
              count_bit <= 2'b00;

              if (count_word == 0) begin // end of word? exit
                state <= DONE;
              end else begin
                count_word <= count_word - 1; // this is here so that once it goes 0, one clock cylce is still executed
              end
            end

            default:;
          endcase
        end // TRANSFER

        DONE: begin
          sck <= 0; // pull everything low
          mosi <= 0;
          report_send <= 1; // send! CS can be pulled high now
          if (cs_in == 1) begin // once wrapper reacted to report_send, go ready
            state <= IDLE;
          end
        end // DONE

      endcase
    end
  end

endmodule
