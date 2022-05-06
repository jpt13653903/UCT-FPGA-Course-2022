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

Implements a 3 MBd UART.  ipClk is assumed to be 50 MHz

To send data:

- Set up ipTxData
- Wait for opTxBusy to be low
- Make ipTxSend high
- Wait for opTxBusy to go high
- Make ipTxSend low

To receive data:

- Wait for opRxValid to be high
- opRxData is valid during the same clock cycle
------------------------------------------------------------------------------*/

module UART(
  input           ipClk,
  input           ipReset,

  input      [7:0]ipTxData,
  input           ipTxSend,
  output reg      opTxBusy,
  output reg      opTx,

  input           ipRx,
  output reg [7:0]opRxData,
  output reg      opRxValid
);
//------------------------------------------------------------------------------

reg Reset;
always @(posedge ipClk) Reset <= ipReset;
//------------------------------------------------------------------------------

reg [4:0]TxBdCount = 0;
reg [7:0]TxData;
reg [2:0]TxCount;

enum {Idle, Sending, Done} TxState;

always @(posedge ipClk) begin
  if(TxBdCount == 16) TxBdCount <= 0;
  else                TxBdCount <= TxBdCount + 1;

  if(Reset) begin
    opTxBusy <= 0;
    opTx     <= 1;

    TxData   <= 8'hX;
    TxCount  <= 8'hX;
    TxState  <= Idle;
  //----------------------------------------------------------------------------

  end else if(TxBdCount == 0) begin
    case(TxState)
      Idle: begin
        TxData  <= ipTxData;
        TxCount <= 0;

        if(ipTxSend) begin
          opTx     <= 0;
          opTxBusy <= 1;
          TxState  <= Sending;
        end
      end
      //------------------------------------------------------------------------

      Sending: begin
        {TxData, opTx} <= {1'b1, TxData};

        if(TxCount == 7) TxState <= Done;
        TxCount <= TxCount + 1;
      end
      //------------------------------------------------------------------------

      Done: begin
        opTx <= 1;
        
        if(~ipTxSend) begin
          opTxBusy <= 0;
          TxState  <= Idle;
        end
      end
      //------------------------------------------------------------------------
      
      default:;
    endcase
  end
end
//------------------------------------------------------------------------------

reg [1:0]Rx;
reg [4:0]RxBdCount;
reg [9:0]RxData;

always @(posedge ipClk) begin
  Rx <= {Rx[0], ipRx};

  if     (Rx[0] != Rx[1]) RxBdCount <=  4; // Supports half stop bits
  else if(RxBdCount == 0) RxBdCount <= 16;
  else                    RxBdCount <= RxBdCount - 1;
  //----------------------------------------------------------------------------

  if(Reset) begin
    opRxData  <= 8'hX;
    opRxValid <= 0;

    RxData    <= 10'h3FF;
  //----------------------------------------------------------------------------

  end else if(RxData[0] == 0 && RxData[9] == 1) begin
    opRxData  <= RxData[8:1];
    opRxValid <= 1;
    RxData    <= 10'h3FF;

  end else begin
    if(RxBdCount == 0) RxData <= {Rx[1], RxData[9:1]};
    opRxValid <= 0;
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

