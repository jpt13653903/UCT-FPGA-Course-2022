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

`timescale 1ns/1ns // unit/precision
//------------------------------------------------------------------------------

import Structures::*;
//------------------------------------------------------------------------------

module UART_Packets_TB;
//------------------------------------------------------------------------------

reg ipClk = 0;
always #10 ipClk <= ~ipClk;
//------------------------------------------------------------------------------

reg ipReset = 1;
initial begin
  @(posedge ipClk);
  @(posedge ipClk);
  @(posedge ipClk);
  ipReset <= 0;
end
//------------------------------------------------------------------------------

UART_PACKET ipTxStream;
wire        opTxReady;
wire        opTx;

integer n;

initial begin
  ipTxStream.Valid = 0;

  @(negedge ipReset);
  @(posedge ipClk);
  @(posedge ipClk);
  @(posedge ipClk);

  ipTxStream.Source      = 8'h01;
  ipTxStream.Destination = 8'h02;
  ipTxStream.Length      = 8'h08;

  forever begin
    n = 0;
    while(n < 8) begin
      @(posedge ipClk);

      if(opTxReady) begin
        ipTxStream.SoP   = (n == 0);
        ipTxStream.EoP   = (n == 7);
        ipTxStream.Data  = n+1;
        ipTxStream.Valid = 1;
        n++;
      end
    end

    forever begin
      @(posedge ipClk);
      if(opTxReady) begin
        ipTxStream.Valid = 0;
        break;
      end
    end

    #($urandom_range(0, 100000));
  end
end
//------------------------------------------------------------------------------

wire        ipRx = opTx;
UART_PACKET opRxStream;
//------------------------------------------------------------------------------

UART_Packets DUT(
  .ipClk     (ipClk     ),
  .ipReset   (ipReset   ),

  .ipTxStream(ipTxStream),
  .opTxReady (opTxReady ),
  .opTx      (opTx      ),

  .ipRx      (ipRx      ),
  .opRxStream(opRxStream)
);
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

