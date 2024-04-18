/*
 * Copyright (c) 2024 Fabio Ramirez Stern
 * SPDX-License-Identifier: Apache-2.0
 */
`include "SPI_master.v"
module SPI_wrapper (
  input wire clk, // 1 MHz clock to run the FSM and other loops
  input wire clk_div, // 100 Hz clock to trigger a time to be send out
  input wire res, // reset, active low
  input wire ena,

  input wire [2:0] min_X0, // minutes
  input wire [3:0] min_0X,
  input wire [2:0] sec_X0, // seconds
  input wire [3:0] sec_0X,
  input wire [3:0] ces_X0, // centiseconds (100th)
  input wire [3:0] ces_0X,

  output wire Mosi,
  output reg  Cs,
  output wire Clk_SPI
);
    
  // FSM
  reg [2:0] state;
  localparam SETUP_ON  = 3'b000;
  localparam SETUP_BCD = 3'b001;
  localparam IDLE      = 3'b100;
  localparam TRANSFER  = 3'b101;
  localparam DONE      = 3'b110;

  reg [15:0] word_out;
  reg [2:0] digit_count;
  wire send_reported;
  wire ready_reported;
  reg reset_master;

  always @(posedge clk) begin  // controlling FSM
    if (!res) begin // active low reset
      Cs <= 1;
      reset_master <= 0;
      word_out <= 16'b0;
      digit_count <= 3'b0;
      state <= SETUP_ON;
    end
    case(state)

      SETUP_ON: begin // send a setup packet enabling BCD
        if (res) begin
          reset_master <= 1;
          if (ready_reported == 1) begin
            word_out <= 16'b0000_1100_0000_0001; // address = shutdown mode, data = device on
            Cs <= 0;
          end
          else if (send_reported == 1) begin // data send, Cs can be pulled high again
            Cs <= 1;
            state <= SETUP_BCD;
          end
        end
      end // SETUP

      SETUP_BCD: begin // send a setup packet enabling BCD
        if (ready_reported == 1) begin
          word_out <= 16'b0000_1001_1111_1111; // address = decode mode, data = BCD for all
          Cs <= 0;
        end
        else if (send_reported == 1) begin // data send, Cs can be pulled high again
          Cs <= 1;
          state <= IDLE;
        end
      end // SETUP

      IDLE: begin
        if (clk_div & ena) begin // wait for the 100Hz clock to get high
          digit_count <= 3'b000;
          state <= TRANSFER;
        end
      end // IDLE

      TRANSFER: begin
        if (ready_reported == 1) begin // wait for TX ready
          case(digit_count)

            3'b000: begin // ces_0X
              word_out <= {8'b0000_0001, 8'b0000_0000 | ces_0X}; // send the 16-bit word
              Cs <= 0; // pull CS low to initiate send
              digit_count <= 3'b001; // advance the position counter
            end

            3'b001: begin // ces_X0
              word_out <= {8'b0000_0010, 8'b0000_0000 | ces_X0};
              Cs <= 0;
              digit_count <= 3'b010;
            end

            3'b010: begin // sec_0X
              word_out <= {8'b0000_0011, 8'b1000_0000 | sec_0X};
              Cs <= 0;
              digit_count <= 3'b011;
            end

            3'b011: begin // sec_X0
              word_out <= {8'b0000_0100, 8'b0000_0000 | sec_X0};
              Cs <= 0;
              digit_count <= 3'b100;
            end

            3'b100: begin // min_0X
              word_out <= {8'b0000_0101, 8'b1000_0000 | min_0X};
              Cs <= 0;
              digit_count <= 3'b101;
            end

            3'b101: begin // min_X0
              word_out <= {8'b0000_0110, 8'b0000_0000 | min_X0};
              Cs <= 0;
              digit_count <= 3'b110;
            end

            3'b110: begin // once send has been complete and CS is high again, switch state
              state <= DONE;
            end

            default:digit_count <= 3'b000;
          endcase

        end else if (send_reported == 1) begin // once data has been send, pull CS high
          Cs <= 1;
        end
      end // TRANSFER

      DONE: begin // wait for the 100 Hz clock to go low again
        if (!clk_div) begin
          state <= IDLE;
        end
      end // DONE

      default:state <= SETUP_ON;
    endcase    
  end

  SPI_Master SPI_Master1 (
    .clk(clk),
    .res(reset_master),
    .cs_in(Cs),
    .word_in(word_out),

    .report_send(send_reported),
    .report_ready(ready_reported),

    .sck(Clk_SPI),
    .mosi(Mosi)
  );

endmodule // SPI_wrapper
