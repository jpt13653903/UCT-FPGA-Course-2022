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

/*------------------------------------------------------------------------------

Defines the registers, and implements a memory-mapped register interface.
------------------------------------------------------------------------------*/

import Structures::*;
//------------------------------------------------------------------------------

module Registers(
  input               ipClk,
  input               ipReset,

  input  RD_REGISTERS ipRdRegisters,
  output WR_REGISTERS opWrRegisters,

  input         [ 7:0]ipAddress,
  input         [31:0]ipWrData,
  input               ipWrEnable,
  output reg    [31:0]opRdData
);
//------------------------------------------------------------------------------

reg Reset;

always @(posedge ipClk) begin
  case(ipAddress)
    8'h00  : opRdData <= ipRdRegisters.ClockTicks;
    8'h01  : opRdData <= ipRdRegisters.Buttons;
    8'h02  : opRdData <= opWrRegisters.LEDs;
    default: opRdData <= 32'hX;
  endcase
  //----------------------------------------------------------------------------

  Reset <= ipReset;

  if(Reset) begin
    opWrRegisters.LEDs <= 0;
  //----------------------------------------------------------------------------

  end else if(ipWrEnable) begin
    case(ipAddress)
      8'h02: opWrRegisters.LEDs <= ipWrData;
      default:;
    endcase
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

