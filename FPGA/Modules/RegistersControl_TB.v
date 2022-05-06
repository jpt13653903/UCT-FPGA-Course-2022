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

module RegistersControl_TB;
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

UART_PACKET opTxStream;
reg         ipTxReady;

always begin
  @(posedge ipClk);
  ipTxReady = 0;
  #2640;
  @(posedge ipClk);
  ipTxReady = 1;
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
    @(posedge ipClk);

    ipRxStream.Destination = 8'h00;
    ipRxStream.Length      = 8'h01;

    ipRxStream.SoP   = 1;
    ipRxStream.EoP   = 1;
    ipRxStream.Data  = 8'h12;
    ipRxStream.Valid = 1;

    @(posedge ipClk);
    ipRxStream.Valid = 0;

    while(~ipTxReady || ~opTxStream.Valid || ~opTxStream.EoP) @(posedge ipClk);

    ipRxStream.Destination = 8'h01;
    ipRxStream.Length      = 8'h05;

    for(n = 0; n < 5; n++) begin
      @(posedge ipClk)
      ipRxStream.SoP   = (n == 0);
      ipRxStream.EoP   = (n == 4);
      ipRxStream.Data  = 8'h12 + 5*n;
      ipRxStream.Valid = 1;
      @(posedge ipClk)
      ipRxStream.Valid = 0;
      #2640;
    end
  end
end
//------------------------------------------------------------------------------

wire  [ 7:0]opAddress;
wire  [31:0]opWrData;
wire        opWrEnable;
reg   [31:0]ipRdData;

always @(posedge ipClk) ipRdData <= {16'h1234, opAddress, 8'hAB};
//------------------------------------------------------------------------------

RegistersControl DUT(
  .ipClk     (ipClk     ),
  .ipReset   (ipReset   ),
                        
  .opTxStream(opTxStream),
  .ipTxReady (ipTxReady ),
                        
  .ipRxStream(ipRxStream),
                        
  .opAddress (opAddress ),
  .opWrData  (opWrData  ),
  .opWrEnable(opWrEnable),
  .ipRdData  (ipRdData  )
);
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

