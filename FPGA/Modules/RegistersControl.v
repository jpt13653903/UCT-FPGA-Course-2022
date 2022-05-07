/*==============================================================================
Copyright (C) John-Philip Taylor
jpt13653903@gmail.com

This file is part of the FPGA Masters Course

This file is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>
==============================================================================*/

/*------------------------------------------------------------------------------

Controls the attached memory (typically control registers) based on the
incoming stream.  The stream expects read instructions on destination port
0x00 and write instructions on port 0x01.

Write instructions are fire-and-forget, whereas read instructions respond with
the data read.  The payloads are symmetrical: one byte address followed
by 4 bytes data, little endian.
------------------------------------------------------------------------------*/

import Structures::*;
//------------------------------------------------------------------------------

module RegistersControl(
  input              ipClk,
  input              ipReset,

  output UART_PACKET opTxStream,
  input              ipTxReady,

  input  UART_PACKET ipRxStream,

  output reg   [ 7:0]opAddress,
  output reg   [31:0]opWrData,
  output reg         opWrEnable,
  input        [31:0]ipRdData
);
//------------------------------------------------------------------------------

reg      Reset;
reg [1:0]Count;

enum {
  Idle,
  Read_Wait, Read_Latch, Read_Send, Read_Done,
  Write
} State;

always @(posedge ipClk) begin
  Reset <= ipReset;

  if(Reset) begin
    opTxStream.Source      <= 8'hX;
    opTxStream.Destination <= 8'hX;
    opTxStream.Length      <= 8'hX;

    opTxStream.SoP         <= 1'hX;
    opTxStream.EoP         <= 1'hX;
    opTxStream.Data        <= 8'hX;
    opTxStream.Valid       <= 0;

    opAddress              <= 8'hX;
    opWrData               <= 8'hX;
    opWrEnable             <= 0;

    Count <= 2'hX;
    State <= Idle;
  //----------------------------------------------------------------------------

  end else begin
    case(State)
      Idle: begin
        opAddress  <= ipRxStream.Data;
        opWrEnable <= 0;

        opTxStream.Source      <= ipRxStream.Destination;
        opTxStream.Destination <= ipRxStream.Source;
        opTxStream.Length      <= 8'h05;

        Count <= 0;

        if(ipRxStream.Valid && ipRxStream.SoP) begin
          case(ipRxStream.Destination)
            8'h00: State <= Read_Wait;
            8'h01: State <= Write;
            default:;
          endcase
        end
      end
      //------------------------------------------------------------------------

      Read_Wait: begin
        State <= Read_Latch; // Single-cycle read latency
      end
      //------------------------------------------------------------------------

      Read_Latch: begin
        opWrData <= ipRdData;

        opTxStream.SoP  <= 1;
        opTxStream.EoP  <= 0;
        opTxStream.Data <= opAddress;

        if(ipTxReady) begin
          opTxStream.Valid <= 1;
          State <= Read_Send;
        end
      end
      //------------------------------------------------------------------------

      Read_Send: begin
        if(ipTxReady) begin
          opTxStream.SoP   <= 0;
          opTxStream.EoP   <= (Count == 3);
          opTxStream.Data  <= opWrData[7:0];
          opTxStream.Valid <= 1;

          opWrData <= {8'hX, opWrData[31:8]};

          if(Count == 3) State <= Read_Done;
          Count <= Count + 1;
        end
      end
      //------------------------------------------------------------------------

      Read_Done: begin
        if(ipTxReady) begin
          opTxStream.Valid <= 0;
          State <= Idle;
        end
      end
      //------------------------------------------------------------------------

      Write: begin
        if(ipRxStream.Valid) begin
          opWrData <= {ipRxStream.Data, opWrData[31:8]};
          if(Count == 3) begin
            opWrEnable <= 1;
            State      <= Idle;
          end
          Count <= Count + 1;
        end
      end
      //------------------------------------------------------------------------

      default:;
    endcase
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

