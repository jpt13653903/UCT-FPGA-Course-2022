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
along with this program.  opData.If not, see <http://www.gnu.org/licenses/>
==============================================================================*/

import Structures::*;
//------------------------------------------------------------------------------

module TimingGenerator(
  input ipClk,
  input ipClkEnable,
  input ipReset,

  input WR_REGISTERS ipWrRegisters,

  output reg [31:0]opNCO_Frequency,
  output reg       opTrigger
);
//------------------------------------------------------------------------------

reg Reset;

always @(posedge ipClk) begin
  Reset <= ipReset;

  if(Reset) begin
    opNCO_Frequency <= 0;
    opTrigger       <= 1;

  end else if(ipClkEnable) begin
    if(opNCO_Frequency <  ipWrRegisters.NCO_Start ||
       opNCO_Frequency >= ipWrRegisters.NCO_Stop  )
    begin
      opTrigger       <= 1;
      opNCO_Frequency <= ipWrRegisters.NCO_Start;

    end else begin
      opTrigger       <= 0;
      opNCO_Frequency <= opNCO_Frequency + ipWrRegisters.NCO_Step;
    end
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

