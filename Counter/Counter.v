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

module Counter(
  input       ipClk,
  input       ipnReset,
  output [7:0]opLED
);
//------------------------------------------------------------------------------

wire      Reset = ~ipnReset;
reg [30:0]Count = 0;

always @(posedge ipClk) begin
  if(Reset) Count <= 0;
  else      Count <= Count + 1;
end

assign opLED = ~Count[30:23];
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

