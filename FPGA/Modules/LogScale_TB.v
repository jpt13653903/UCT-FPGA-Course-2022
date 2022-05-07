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

module LogScale_TB;
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

reg [23:0]ipInput;
reg       ipValid;

wire [ 7:0]opOutput;
wire       opValid;

integer Expected;

initial begin
  ipInput = 0;
  ipValid = 0;

  @(negedge ipReset);
  @(posedge ipClk);
  @(posedge ipClk);
  @(posedge ipClk);

  forever begin
    ipValid <= 1;

    @(posedge ipClk);
    ipValid <= 0;

    while(!opValid) @(posedge ipClk);

    Expected = (10.0*$log10(ipInput/real'(1 << 24)) + 50.0) / 50.0 * 256.0;
    assert(opOutput == Expected || opOutput == Expected-1) else begin
      $error("Wrong answer");
      $display("    Input  = %06X", ipInput );
      $display("    Output = %02X", opOutput);
      $display("    Expect = %02X", Expected);
    end

    ipInput <= ipInput + 1;
  end
end
//------------------------------------------------------------------------------

LogScale DUT(
  .ipClk   (ipClk  ),
  .ipReset (ipReset),

  .ipInput (ipInput ),
  .ipValid (ipValid ),

  .opOutput(opOutput),
  .opValid (opValid )
);
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

