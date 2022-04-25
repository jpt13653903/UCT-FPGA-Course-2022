//==============================================================================
// Copyright (C) John-Philip Taylor
// jpt13653903@gmail.com
//
// This file is part of a library
//
// This file is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>
//==============================================================================

module ADXL345 #(
  parameter Clock_Div = 5 // 5 MHz SClk on a 50 MHz Clk
)(
  input Clk, Reset,

  // 2's Compliment Output
  output reg [15:0]X,
  output reg [15:0]Y,
  output reg [15:0]Z,

  // Physical device interface
  output reg nCS, SClk, SDI,
  input      SDO
);
//------------------------------------------------------------------------------

  reg      Local_Reset;
  reg [3:0]Clock_Count  = 0;
  wire     Clock_Enable = (Clock_Count == Clock_Div);
//------------------------------------------------------------------------------

  reg [ 4:0]Count;
  reg [15:0]WriteData; // R/W, MB, Address, Byte
  reg [15:0]ReadData;  // 2 Bytes
//------------------------------------------------------------------------------

 typedef enum {
   Setup,
   ReadX, ReadY, ReadZ,
   Transaction
 } STATE;

 STATE State;
 STATE RetState; // Used for function calls

//------------------------------------------------------------------------------

  always @(posedge Clk) begin
    Local_Reset <= Reset;

    if(Clock_Enable) Clock_Count <= 4'd1;
    else             Clock_Count <= Clock_Count + 1'b1;

    if(Local_Reset) begin
      nCS   <= 1'b1;
      SClk  <= 1'b1;
      SDI   <= 1'b1;
      State <= Setup;
//------------------------------------------------------------------------------

    end else if(Clock_Enable) begin
      case(State)
        Setup: begin
          // SPI 4-wire; Full-res; Right-justify; 4g Range
          WriteData <= {2'b00, 6'h31, 8'b0000_1001};
          Count     <= 5'd16;
          State     <= Transaction;
          RetState  <= ReadX;
        end
//------------------------------------------------------------------------------

        ReadX: begin
          Z         <= {ReadData[7:0], ReadData[15:8]};
          WriteData <= {2'b11, 6'h32, 8'd0};
          Count     <= 5'd24;
          State     <= Transaction;
          RetState  <= ReadY;
        end
//------------------------------------------------------------------------------

        ReadY: begin
          X         <= {ReadData[7:0], ReadData[15:8]};
          WriteData <= {2'b11, 6'h34, 8'd0};
          Count     <= 5'd24;
          State     <= Transaction;
          RetState  <= ReadZ;
        end
//------------------------------------------------------------------------------

        ReadZ: begin
          Y         <= {ReadData[7:0], ReadData[15:8]};
          WriteData <= {2'b11, 6'h36, 8'd0};
          Count     <= 5'd24;
          State     <= Transaction;
          RetState  <= ReadX;
        end
//------------------------------------------------------------------------------

        Transaction: begin
          if(nCS) begin
            nCS <= 1'b0;

          end else begin
            if(SClk) begin
              if(Count == 0) begin
                nCS <= 1'b1; State <= RetState;
              end else begin
                SClk <= 1'b0;
                {SDI, WriteData[15:1]} <= WriteData;
              end
              Count    <= Count - 1'b1;
              ReadData <= {ReadData[14:0], SDO};

            end else begin
              SClk <= 1'b1;
            end
          end
        end
//------------------------------------------------------------------------------

        default:;
      endcase
    end
  end
endmodule
//------------------------------------------------------------------------------

