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

module TimingGenerator_TB;
//------------------------------------------------------------------------------

reg ipClk = 0;
always #10 ipClk <= ~ipClk;
//------------------------------------------------------------------------------

reg ipClkEnable = 0;
always begin
  #22635;
  @(posedge ipClk) ipClkEnable <= 1;
  @(posedge ipClk) ipClkEnable <= 0;
end
//------------------------------------------------------------------------------

reg ipReset = 1;
initial begin
  @(posedge ipClk);
  @(posedge ipClk);
  @(posedge ipClk);
  ipReset <= 0;
end
//------------------------------------------------------------------------------

WR_REGISTERS ipWrRegisters;
assign ipWrRegisters.NCO_Start = $floor( 1000.0 * (2.0**32/50e6));
assign ipWrRegisters.NCO_Stop  = $floor(10000.0 * (2.0**32/50e6));
assign ipWrRegisters.NCO_Step  = 10;
//------------------------------------------------------------------------------

wire [31:0]opNCO_Frequency;
wire       opTrigger;

TimingGenerator DUT(
  .ipClk          (ipClk      ),
  .ipClkEnable    (ipClkEnable),
  .ipReset        (ipReset    ),

  .ipWrRegisters  (ipWrRegisters),

  .opNCO_Frequency(opNCO_Frequency),
  .opTrigger      (opTrigger)
);
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

