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
module UART_TB;
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

reg  [7:0]ipTxData;
reg       ipTxSend;
wire      opTxBusy;
wire      opTx;

integer TxBit;

initial begin
  ipTxSend = 0;

  @(negedge ipReset);
  @(posedge ipClk);

  forever begin
    ipTxData = $urandom_range(0, 255);
    if(opTxBusy) @(negedge opTxBusy);

    assert(opTx == 1) else
      $error("Tx should idle high");

    @(posedge ipClk);
    ipTxSend = 1;

    @(posedge opTxBusy);
    @(posedge ipClk);
    ipTxSend = 0;

    #4340;
    assert(opTx == 0) else
      $error("Expecting start bit");

    for(TxBit = 0; TxBit < 8; TxBit++) begin
      #8681;
      assert(opTx == ipTxData[TxBit]) else
        $error("Incorrect data bit");
    end

    #8681;
    assert(opTx == 1) else
      $error("Expecting stop bit");
  end
end
//------------------------------------------------------------------------------

reg       ipRx;
wire [7:0]opRxData;
wire      opRxValid;

reg  [7:0]RxData;
integer   RxBit;

initial begin
  ipRx = 1;

  @(negedge ipReset);
  @(posedge ipClk);

  forever begin
    #($urandom_range(5000, 50000));

    RxData = $urandom_range(0, 255);

    ipRx = 0;
    #8681;
    for(RxBit = 0; RxBit < 8; RxBit++) begin
      ipRx = RxData[RxBit];
      #8681;
    end
    ipRx = 1;

    @(posedge opRxValid);
    #1;
    assert(opRxData == RxData) else
      $error("Rx Data Error");
  end
end
//------------------------------------------------------------------------------

UART DUT(
  .ipClk    (ipClk    ),
  .ipReset  (ipReset  ),
                      
  .ipTxData (ipTxData ),
  .ipTxSend (ipTxSend ),
  .opTxBusy (opTxBusy ),
  .opTx     (opTx     ),
                      
  .ipRx     (ipRx     ),
  .opRxData (opRxData ),
  .opRxValid(opRxValid)
);
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

