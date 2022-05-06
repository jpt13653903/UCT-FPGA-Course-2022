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

module Streamer(
  input       ipClk,
  input       ipnReset,

  input       ipUART_Rx,
  output      opUART_Tx,

  input  [3:0]ipButtons,
  output [7:0]opLED
);
//------------------------------------------------------------------------------

wire Reset = ~ipnReset;
//------------------------------------------------------------------------------

UART_PACKET UART_TxStream;
wire        UART_TxReady;

UART_PACKET UART_RxStream;

UART_Packets UART_Packets_Inst(
  .ipClk     (ipClk),
  .ipReset   (Reset),

  .ipTxStream(  UART_TxStream),
  .opTxReady (  UART_TxReady ),
  .opTx      (opUART_Tx      ),

  .ipRx      (ipUART_Rx    ),
  .opRxStream(UART_RxStream)
);
//------------------------------------------------------------------------------

wire [ 7:0]Registers_Address;
wire [31:0]Registers_WrData;
wire       Registers_WrEnable;
wire [31:0]Registers_RdData;

RegistersControl RegistersControl_Inst(
  .ipClk     (ipClk),
  .ipReset   (Reset),

  .opTxStream(UART_TxStream),
  .ipTxReady (UART_TxReady ),

  .ipRxStream(UART_RxStream),

  .opAddress (Registers_Address ),
  .opWrData  (Registers_WrData  ),
  .opWrEnable(Registers_WrEnable),
  .ipRdData  (Registers_RdData  )
);
//------------------------------------------------------------------------------

RD_REGISTERS RdRegisters;
WR_REGISTERS WrRegisters;

Registers Registers_Inst(
  .ipClk        (ipClk),
  .ipReset      (Reset),

  .ipRdRegisters(RdRegisters),
  .opWrRegisters(WrRegisters),

  .ipAddress    (Registers_Address ),
  .ipWrData     (Registers_WrData  ),
  .ipWrEnable   (Registers_WrEnable),
  .opRdData     (Registers_RdData  )
);
//------------------------------------------------------------------------------

always @(posedge ipClk) begin
  if(Reset) RdRegisters.ClockTicks <= 0;
  else      RdRegisters.ClockTicks <= RdRegisters.ClockTicks + 1;
end
//------------------------------------------------------------------------------

assign RdRegisters.Buttons = ~ipButtons;
assign opLED = ~WrRegisters.LEDs;
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

