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

module ReceiveStream_TB;
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

UART_PACKET ipRxStream;

integer n;

initial begin
  ipRxStream.Source = 8'hAA;
  ipRxStream.Valid  = 0;

  @(negedge ipReset);
  @(posedge ipClk);
  @(posedge ipClk);
  @(posedge ipClk);

  forever begin
    ipRxStream.Destination = 8'h10;
    ipRxStream.Length      = 8'h00; // 256-length packet

    for(n = 0; n < 256; n++) begin
      @(posedge ipClk);
      ipRxStream.SoP   = (n ==   0);
      ipRxStream.EoP   = (n == 255);
      ipRxStream.Data  = n;
      ipRxStream.Valid = 1;

      @(posedge ipClk);
      ipRxStream.Valid = 0;
      #15;
    end
  end
end
//------------------------------------------------------------------------------

wire  [13:0]opFIFO_Space;
DATA_STREAM opData;

ReceiveStream DUT(
  .ipClk       (ipClk  ),
  .ipReset     (ipReset),

  .opFIFO_Space(opFIFO_Space),
  .ipRxStream  (ipRxStream  ),

  .opData      (opData)
);
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

