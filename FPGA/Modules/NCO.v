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

import Structures::*;
//------------------------------------------------------------------------------

module NCO(
  input ipClk,
  input ipReset,

  input [31:0]ipFrequency,

  output COMPLEX_STREAM opOutput
);
//------------------------------------------------------------------------------

reg       Reset;
reg [31:0]Phase;

always @(posedge ipClk) begin
  Reset <= ipReset;

  if(Reset) Phase <= 0;
  else      Phase <= Phase + ipFrequency;
end
//------------------------------------------------------------------------------

SineLUT LUT(
  .ClockA  (ipClk),
  .ResetA  (ipReset),
  .ClockEnA(1'b1),
  .AddressA(Phase[31:22]),
  .DataInA (18'h0),
  .WrA     ( 1'b0),
  .QA      (opOutput.Q),

  .ClockB  (ipClk),
  .ResetB  (ipReset),
  .ClockEnB(1'b1),
  .AddressB(Phase[31:22] + 10'h100),
  .DataInB (18'h0),
  .WrB     ( 1'b0),
  .QB      (opOutput.I)
);
assign opOutput.Valid = 1'b1;
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

