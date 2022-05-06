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

module PWM(
  input      ipClk,
  input [7:0]ipDutyCycle,
  output reg opOutput
);
//------------------------------------------------------------------------------

reg [7:0]D;
reg [7:0]Count = 0; // Initialisation for simulation only
//------------------------------------------------------------------------------

always @(posedge ipClk) begin
  if(&Count) D <= ipDutyCycle;

  opOutput <= (D > Count);
  Count    <= Count + 1'b1;
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

