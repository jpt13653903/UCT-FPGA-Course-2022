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

module Mixer_TB;
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

DATA_STREAM    ipInput;
COMPLEX_STREAM ipNCO;

real a, b, y;

always begin
  ipInput.Valid <= 0;

  @(negedge ipReset);
  @(posedge ipClk);

  forever begin
    @(posedge ipClk);

    ipInput.Data  <= $urandom_range(0, 2**16 - 1);
    ipInput.Valid <= 1;

    ipNCO.I     <= $urandom_range(0, 2**18 - 1);
    ipNCO.Q     <= $urandom_range(0, 2**18 - 1);
    ipNCO.Valid <= 1;

    @(posedge ipClk);
    ipInput.Valid <= 0;

    @(posedge opOutput.Valid);
    #1;

    a = real'(ipInput.Data) / 2**15;
    b = real'(ipNCO  .I   ) / 2**17;
    y = a * b;
    assert(opOutput.I == $floor(y * 2**17)) else
      $error("Error on Output I: expecting %g, got %g", y, real'(opOutput.I) / 2**17);

    a = real'(ipInput.Data) / 2**15;
    b = real'(ipNCO  .Q   ) / 2**17;
    y = a * b;
    assert(opOutput.Q == $floor(y * 2**17)) else
      $error("Error on Output Q: expecting %g, got %g", y, real'(opOutput.Q) / 2**17);

    #1;
  end
end
//------------------------------------------------------------------------------

COMPLEX_STREAM opOutput;

Mixer DUT(
  .ipClk   (ipClk   ),
  .ipReset (ipReset ),

  .ipInput (ipInput ),
  .ipNCO   (ipNCO   ),
  .opOutput(opOutput)
);
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

