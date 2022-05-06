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

import Structures::*;
//------------------------------------------------------------------------------

module UART_Packets(
  input              ipClk,
  input              ipReset,

  input  UART_PACKET ipTxStream,
  output reg         opTxReady,
  output             opTx,

  input              ipRx,
  output UART_PACKET opRxStream
);
//------------------------------------------------------------------------------

reg  [7:0]UART_TxData;
reg       UART_TxSend;
wire      UART_TxBusy;

wire [7:0]UART_RxData;
wire      UART_RxValid;

UART UART_Inst(
  .ipClk    (ipClk  ),
  .ipReset  (ipReset),

  .ipTxData (UART_TxData),
  .ipTxSend (UART_TxSend),
  .opTxBusy (UART_TxBusy),
  .opTx     (opTx       ),

  .ipRx     (ipRx        ),
  .opRxData (UART_RxData ),
  .opRxValid(UART_RxValid)
);
//------------------------------------------------------------------------------

reg Reset;
always @(posedge ipClk) Reset <= ipReset;
//------------------------------------------------------------------------------

UART_PACKET TxBuffer;
reg    [7:0]TxCount;

enum {
  Tx_Idle,
  Tx_Sync,
  Tx_Destination,
  Tx_Source,
  Tx_Length,
  Tx_Payload,
  Tx_WaitForData
} TxState;

always @(posedge ipClk) begin
  if(Reset) begin
    opTxReady <= 0;

    UART_TxData <= 8'hX;
    UART_TxSend <= 0;

    TxCount <= 8'hX;
    TxState <= Tx_Idle;
  //----------------------------------------------------------------------------

  end else begin
    case(TxState)
      Tx_Idle: begin
        if(opTxReady) begin
          TxBuffer <= ipTxStream;
          TxCount  <= ipTxStream.Length-1;

          if(ipTxStream.Valid && ipTxStream.SoP) begin
            opTxReady <= 0;
            TxState   <= Tx_Sync;
          end
        end else begin
          opTxReady <= 1;
        end
      end
      //------------------------------------------------------------------------

      Tx_Sync: begin
        if(~UART_TxSend && ~UART_TxBusy) begin
          UART_TxData <= 8'h55;
          UART_TxSend <= 1;
        end else if(UART_TxSend && UART_TxBusy) begin
          UART_TxSend <= 0;
          TxState     <= Tx_Destination;
        end
      end
      //------------------------------------------------------------------------

      Tx_Destination: begin
        if(~UART_TxSend && ~UART_TxBusy) begin
          UART_TxData <= TxBuffer.Destination;
          UART_TxSend <= 1;
        end else if(UART_TxSend && UART_TxBusy) begin
          UART_TxSend <= 0;
          TxState     <= Tx_Source;
        end
      end
      //------------------------------------------------------------------------

      Tx_Source: begin
        if(~UART_TxSend && ~UART_TxBusy) begin
          UART_TxData <= TxBuffer.Source;
          UART_TxSend <= 1;
        end else if(UART_TxSend && UART_TxBusy) begin
          UART_TxSend <= 0;
          TxState     <= Tx_Length;
        end
      end
      //------------------------------------------------------------------------

      Tx_Length: begin
        if(~UART_TxSend && ~UART_TxBusy) begin
          UART_TxData <= TxBuffer.Length;
          UART_TxSend <= 1;
        end else if(UART_TxSend && UART_TxBusy) begin
          UART_TxSend <= 0;
          TxState     <= Tx_Payload;
        end
      end
      //------------------------------------------------------------------------

      Tx_Payload: begin
        if(~UART_TxSend && ~UART_TxBusy) begin
          UART_TxData <= TxBuffer.Data;
          UART_TxSend <= 1;

          if(TxCount != 0) begin
            opTxReady <= 1;
            TxState   <= Tx_WaitForData;
          end

        end else if(UART_TxSend && UART_TxBusy) begin
          UART_TxSend <= 0;
          if(TxCount == 0) TxState <= Tx_Idle;
          TxCount <= TxCount - 1;
        end
      end
      //------------------------------------------------------------------------

      Tx_WaitForData: begin
        if(ipTxStream.Valid) begin
          TxBuffer.Data <= ipTxStream.Data;
          opTxReady     <= 0;
          TxState       <= Tx_Payload;
        end
      end
      //------------------------------------------------------------------------

      default:;
    endcase
  end
end
//------------------------------------------------------------------------------

reg [7:0]RxCount;

enum {
  Rx_Idle,
  Rx_Destination,
  Rx_Source,
  Rx_Length,
  Rx_Payload
} RxState;

always @(posedge ipClk) begin
  if(Reset) begin
    opRxStream.Source      <= 8'hX;
    opRxStream.Destination <= 8'hX;
    opRxStream.Length      <= 8'hX;

    opRxStream.SoP         <= 1'hX;
    opRxStream.EoP         <= 1'hX;
    opRxStream.Data        <= 8'hX;
    opRxStream.Valid       <= 0;

    RxCount <= 8'hX;
    RxState <= Rx_Idle;
  //----------------------------------------------------------------------------

  end else begin
    case(RxState)
      Rx_Idle: begin
        opRxStream.SoP   <= 0;
        opRxStream.EoP   <= 0;
        opRxStream.Valid <= 0;

        if(UART_RxValid && UART_RxData == 8'h55) begin
          RxState <= Rx_Destination;
        end;
      end
      //------------------------------------------------------------------------

      Rx_Destination: begin
        if(UART_RxValid) begin
          opRxStream.Destination <= UART_RxData;
          RxState <= Rx_Source;
        end
      end
      //------------------------------------------------------------------------

      Rx_Source: begin
        if(UART_RxValid) begin
          opRxStream.Source <= UART_RxData;
          RxState <= Rx_Length;
        end
      end
      //------------------------------------------------------------------------

      Rx_Length: begin
        if(UART_RxValid) begin
          opRxStream.Length <= UART_RxData;
          opRxStream.SoP    <= 1;
          RxCount <= UART_RxData - 1;
          RxState <= Rx_Payload;
        end
      end
      //------------------------------------------------------------------------

      Rx_Payload: begin
        if(opRxStream.Valid) opRxStream.SoP <= 0;

        opRxStream.Data  <= UART_RxData;
        opRxStream.Valid <= UART_RxValid;

        if(UART_RxValid) begin
          if(RxCount == 0) begin
            opRxStream.EoP <= 1;
            RxState <= Rx_Idle;
          end else begin
            RxCount <= RxCount - 1;
          end
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

