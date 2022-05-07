//==============================================================================
// Copyright (C) John-Philip Taylor
// jpt13653903@gmail.com
//
// This file is part of a library
//
// This file is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>
//==============================================================================

`timescale 1ns/1ns
//------------------------------------------------------------------------------

import Structures::*;
//------------------------------------------------------------------------------

module EnergyCounter_TB;
//------------------------------------------------------------------------------

// Clock
reg ipClk = 0;
always #10 ipClk <= ~ipClk;
//------------------------------------------------------------------------------

// Reset
reg ipReset = 1;
initial #100 ipReset <= 0;
//------------------------------------------------------------------------------

reg [4:0]ipWindowSize = 4;

COMPLEX_STREAM ipInput;
initial begin
  ipInput.I     <= 18'h20000;
  ipInput.Q     <= 18'h20000;
  ipInput.Valid <= 0;
end

always #43000 ipInput.I <= ipInput.I + 100;
always #89000 ipInput.Q <= ipInput.Q + 100;

always begin
  #22656;
  @(posedge ipClk) ipInput.Valid = 1;
  @(posedge ipClk) ipInput.Valid = 0;
end
//------------------------------------------------------------------------------

wire [7:0]opOutput;

EnergyCounter DUT(
  .ipClk       (ipClk       ),
  .ipReset     (ipReset     ),
                            
  .ipWindowSize(ipWindowSize),
                            
  .ipInput     (ipInput     ),
  .opOutput    (opOutput    )
);
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

