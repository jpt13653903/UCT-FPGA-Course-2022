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

`timescale 1ns/1ps
module ADXL345_TB;
//------------------------------------------------------------------------------

// Clock
reg Clk_100M = 0;
always #5 Clk_100M <= ~Clk_100M;
//------------------------------------------------------------------------------

// Reset
reg Reset = 1;
initial #20 Reset <= 0;
//------------------------------------------------------------------------------

// DUT
wire [15:0]X, Y, Z;
wire nCS, SClk, SDI;
reg  SDO = 0;

ADXL345 #(10) Accelerometer( // Set parameter for 100 MHz
  Clk_100M, Reset,
  X, Y, Z,
  nCS, SClk, SDI, SDO
);
//------------------------------------------------------------------------------

reg [ 7:0]DataIn;
reg [15:0]DataOut = 0;

integer n;
always begin
  @(negedge nCS);

  // Instruction word
  for(n = 7; n >= 0; n--) begin
    @(negedge SClk);
    DataIn[n] = SDI;
  end

  // The first data word
  for(n = 7; n >= 0; n--) begin
    @(negedge SClk); #40 // Output delay;
    SDO <= DataOut[n];
  end

  // The optional second data word
  if(DataIn[6]) begin // More bits
    for(n = 15; n >= 8; n--) begin
      @(negedge SClk); #40 // Output delay;
      SDO <= DataOut[n];
    end
  end

  @(posedge nCS);

  DataOut = DataOut + 1;
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

