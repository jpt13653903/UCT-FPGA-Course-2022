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

module NCO_TB;
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

reg [31:0]ipFrequency = $floor(1e3 * (2.0**32)/50e6 + 0.5);
//------------------------------------------------------------------------------

COMPLEX_STREAM opOutput;

NCO DUT(
  .ipClk      (ipClk      ),
  .ipReset    (ipReset    ),

  .ipFrequency(ipFrequency),

  .opOutput   (opOutput   )
);
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

