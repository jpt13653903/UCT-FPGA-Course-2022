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

Receives a 16-bit data stream on port 0x10 of the incoming stream.  The 
resulting data is played out at 44 100 kSps.
------------------------------------------------------------------------------*/

import Structures::*;
//------------------------------------------------------------------------------

module ReceiveStream(
  input              ipClk,
  input              ipReset,

  output reg   [12:0]opFIFO_Space, // In bytes
  input  UART_PACKET ipRxStream,

  output DATA_STREAM opData
);
//------------------------------------------------------------------------------

reg  [11:0]WrAddress;
reg  [15:0]WrData;
reg        WrEnable;

reg  [11:0]RdAddress;
wire [15:0]RdData;

FIFO FIFO_Inst(
  .ClockA  (ipClk),
  .ResetA  (ipReset),
  .ClockEnA(1'b1),
  .AddressA(WrAddress),
  .DataInA (WrData),
  .WrA     (WrEnable),
  .QA      (),

  .ClockB  (ipClk),
  .ResetB  (ipReset),
  .ClockEnB(1'b1),
  .AddressB(RdAddress),
  .DataInB (16'b0),
  .WrB     (1'b0),
  .QB      (RdData)
);
//------------------------------------------------------------------------------

reg        Reset;
wire [11:0]FIFO_Length = WrAddress - RdAddress;

always @(posedge ipClk) begin
  Reset        <= ipReset;
  opFIFO_Space <= {12'hFFF - FIFO_Length, 1'b0};
end
//------------------------------------------------------------------------------

reg [7:0]RxCount;

enum {
  Idle,
  Receiving
} State;

always @(posedge ipClk) begin
  if(Reset) begin
    WrAddress    <= 0;
    WrData       <= 'hX;
    WrEnable     <= 0;

    RxCount      <= 8'hX;
    State        <= Idle;
  //----------------------------------------------------------------------------

  end else begin
    case(State)
      Idle: begin
        if(WrEnable) begin
          WrAddress <= WrAddress + 1;
          WrEnable  <= 0;
        end

        if(ipRxStream.Valid && ipRxStream.SoP && ipRxStream.Destination == 8'h10) begin
          WrData[7:0] <= ipRxStream.Data;
          RxCount     <= ipRxStream.Length - 1;
          State       <= Receiving;
        end
      end
      //------------------------------------------------------------------------

      Receiving: begin
        if(ipRxStream.Valid) begin
          if(RxCount[0]) begin
            WrData[15:8] <= ipRxStream.Data;
            WrEnable     <= 1;
          end else begin
            WrAddress    <= WrAddress + 1;
            WrData[ 7:0] <= ipRxStream.Data;
            WrEnable     <= 0;
          end

          if(RxCount == 1) State <= Idle;
          RxCount <= RxCount - 1;

        end else begin
          WrEnable <= 0;
        end
      end
      //------------------------------------------------------------------------

      default:;
    endcase
  end
end
//------------------------------------------------------------------------------

reg [10:0]TxCount = 0; // Initialisation for simulation only

always @(posedge ipClk) begin
  if(TxCount == 0) TxCount <= 1133;
  else             TxCount <= TxCount - 1;

  if(Reset) begin
    opData.Data  <= 16'hX;
    opData.Valid <= 0;
    RdAddress    <= 0;

  end else if(TxCount == 0 && FIFO_Length > 0) begin
    opData.Data  <= RdData;
    opData.Valid <= 1;
    RdAddress    <= RdAddress + 1;

  end else begin
    opData.Valid <= 0;
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

