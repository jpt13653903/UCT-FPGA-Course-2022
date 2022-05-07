/*==============================================================================
Copyright (C) John-Philip Taylor
jpt13653903@gmail.com

This file is part of a library

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

`timescale 1ns/1ns
//------------------------------------------------------------------------------

import Structures::*;
//------------------------------------------------------------------------------

module IIR_Filter_TB;
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

COMPLEX_STREAM ipInput;

integer n;

initial begin
  ipInput.Valid = 0;

  @(negedge ipReset);
  @(posedge ipClk);
  @(posedge ipClk);
  @(posedge ipClk);

  forever begin
    ipInput.I = 18'h00000;
    ipInput.Q = 18'h1FFFF;
    for(n = 0; n < 1103; n++) begin
      @(posedge ipClk);
      ipInput.Valid = 1;
      @(posedge ipClk);
      ipInput.Valid = 0;
      #22636;
    end

    ipInput.I = 18'h1FFFF;
    ipInput.Q = 18'h00000;
    for(n = 0; n < 1103; n++) begin
      @(posedge ipClk);
      ipInput.Valid = 1;
      @(posedge ipClk);
      ipInput.Valid = 0;
      #22636;
    end

    ipInput.I = 18'h00000;
    ipInput.Q = 18'h20000;
    for(n = 0; n < 1103; n++) begin
      @(posedge ipClk);
      ipInput.Valid = 1;
      @(posedge ipClk);
      ipInput.Valid = 0;
      #22636;
    end

    ipInput.I = 18'h20000;
    ipInput.Q = 18'h00000;
    for(n = 0; n < 1103; n++) begin
      @(posedge ipClk);
      ipInput.Valid = 1;
      @(posedge ipClk);
      ipInput.Valid = 0;
      #22636;
    end
  end
end
//------------------------------------------------------------------------------

COMPLEX_STREAM opOutput;

IIR_Filter DUT(
  .ipClk  (ipClk  ),
  .ipReset(ipReset),

  .ipFrequencySelect(3'd2), // 1 -> 4 => 10, 100, 1k and 10k

  .ipInput (ipInput ),
  .opOutput(opOutput)
);
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

