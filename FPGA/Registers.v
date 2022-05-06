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

module Registers(
  input       ipClk,
  input       ipnReset,

  input       ipUART_Rx,
  output      opUART_Tx,

  output [7:0]opLED
);
//------------------------------------------------------------------------------

wire      Reset = ~ipnReset;
reg [30:0]Count = 0;

always @(posedge ipClk) begin
  if(Reset) Count <= 0;
  else      Count <= Count + 1;
end

assign opLED = ~Count[30:23];
//------------------------------------------------------------------------------

reg  [7:0]UART_TxData;
reg       UART_TxSend;
wire      UART_TxBusy;

wire [7:0]UART_RxData;
wire      UART_RxValid;

UART UART_Inst(
  .ipClk    (ipClk),
  .ipReset  (Reset),

  .ipTxData (  UART_TxData),
  .ipTxSend (  UART_TxSend),
  .opTxBusy (  UART_TxBusy),
  .opTx     (opUART_Tx    ),

  .ipRx     (ipUART_Rx     ),
  .opRxData (  UART_RxData ),
  .opRxValid(  UART_RxValid)
);

always @(posedge ipClk) begin
  if(~UART_TxSend && ~UART_TxBusy) begin
    case(UART_RxData) inside
      8'h0D    : UART_TxData <= 8'h0A; // Change enter to linefeed
      "0"      : UART_TxData <= 8'h0D; // Change 0 to carriage return
      ["A":"Z"]: UART_TxData <= UART_RxData ^ 8'h20;
      ["a":"z"]: UART_TxData <= UART_RxData ^ 8'h20;
      default  : UART_TxData <= UART_RxData;
    endcase
    UART_TxSend <= UART_RxValid;

  end else if(UART_TxSend && UART_TxBusy) begin
    UART_TxSend <= 0;
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

