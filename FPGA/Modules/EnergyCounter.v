//==============================================================================
// Copyright (C) John-Philip Taylor
// jpt13653903@gmail.com
//
// This file is part of the FPGA Masters Course
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

import Structures::*;
//------------------------------------------------------------------------------

module EnergyCounter(
  input           ipClk,
  input           ipReset,

  input      [4:0]ipWindowSize, // Real size = 2^ipWindowSize samples

  COMPLEX_STREAM  ipInput,
  output reg [7:0]opOutput
);
//------------------------------------------------------------------------------

reg [30:0]N;
reg [67:0]Sum;
reg [23:0]AveragePower;
reg [36:0]AveragePower_1;
reg       AveragePower_Valid;

always @(*) begin
  case(ipWindowSize)
    5'h00  : begin N = 31'h_0000_0000; AveragePower_1 = Sum[36: 0]; end
    5'h01  : begin N = 31'h_0000_0001; AveragePower_1 = Sum[37: 1]; end
    5'h02  : begin N = 31'h_0000_0003; AveragePower_1 = Sum[38: 2]; end
    5'h03  : begin N = 31'h_0000_0007; AveragePower_1 = Sum[39: 3]; end
    5'h04  : begin N = 31'h_0000_000F; AveragePower_1 = Sum[40: 4]; end
    5'h05  : begin N = 31'h_0000_001F; AveragePower_1 = Sum[41: 5]; end
    5'h06  : begin N = 31'h_0000_003F; AveragePower_1 = Sum[42: 6]; end
    5'h07  : begin N = 31'h_0000_007F; AveragePower_1 = Sum[43: 7]; end
    5'h08  : begin N = 31'h_0000_00FF; AveragePower_1 = Sum[44: 8]; end
    5'h09  : begin N = 31'h_0000_01FF; AveragePower_1 = Sum[45: 9]; end
    5'h0A  : begin N = 31'h_0000_03FF; AveragePower_1 = Sum[46:10]; end
    5'h0B  : begin N = 31'h_0000_07FF; AveragePower_1 = Sum[47:11]; end
    5'h0C  : begin N = 31'h_0000_0FFF; AveragePower_1 = Sum[48:12]; end
    5'h0D  : begin N = 31'h_0000_1FFF; AveragePower_1 = Sum[49:13]; end
    5'h0E  : begin N = 31'h_0000_3FFF; AveragePower_1 = Sum[50:14]; end
    5'h0F  : begin N = 31'h_0000_7FFF; AveragePower_1 = Sum[51:15]; end
    5'h10  : begin N = 31'h_0000_FFFF; AveragePower_1 = Sum[52:16]; end
    5'h11  : begin N = 31'h_0001_FFFF; AveragePower_1 = Sum[53:17]; end
    5'h12  : begin N = 31'h_0003_FFFF; AveragePower_1 = Sum[54:18]; end
    5'h13  : begin N = 31'h_0007_FFFF; AveragePower_1 = Sum[55:19]; end
    5'h14  : begin N = 31'h_000F_FFFF; AveragePower_1 = Sum[56:20]; end
    5'h15  : begin N = 31'h_001F_FFFF; AveragePower_1 = Sum[57:21]; end
    5'h16  : begin N = 31'h_003F_FFFF; AveragePower_1 = Sum[58:22]; end
    5'h17  : begin N = 31'h_007F_FFFF; AveragePower_1 = Sum[59:23]; end
    5'h18  : begin N = 31'h_00FF_FFFF; AveragePower_1 = Sum[60:24]; end
    5'h19  : begin N = 31'h_01FF_FFFF; AveragePower_1 = Sum[61:25]; end
    5'h1A  : begin N = 31'h_03FF_FFFF; AveragePower_1 = Sum[62:26]; end
    5'h1B  : begin N = 31'h_07FF_FFFF; AveragePower_1 = Sum[63:27]; end
    5'h1C  : begin N = 31'h_0FFF_FFFF; AveragePower_1 = Sum[64:28]; end
    5'h1D  : begin N = 31'h_1FFF_FFFF; AveragePower_1 = Sum[65:29]; end
    5'h1E  : begin N = 31'h_3FFF_FFFF; AveragePower_1 = Sum[66:30]; end
    5'h1F  : begin N = 31'h_7FFF_FFFF; AveragePower_1 = Sum[67:31]; end
    default: begin N = 31'h_7FFF_FFFF; AveragePower_1 = Sum[67:31]; end
  endcase
end
//------------------------------------------------------------------------------

reg       Reset;
reg [31:0]Count;

wire [35:0]Power_I = ipInput.I * ipInput.I;
wire [35:0]Power_Q = ipInput.Q * ipInput.Q;
wire [36:0]Power   = {1'b0,  Power_I} + {1'b0,  Power_Q};

always @(posedge ipClk) begin
  Reset <= ipReset;

  if(Reset) begin
    Sum   <= 0;
    Count <= 0;

  end else if(ipInput.Valid) begin
    if(Count >= N) begin
      Sum   <= Power;
      Count <= 0;

      if(|AveragePower_1[36:34]) AveragePower <= ~24'd0;
      else                       AveragePower <= AveragePower_1[33:10];
      AveragePower_Valid <= 1;

    end else begin
      Sum   <= Sum   + Power;
      Count <= Count + 1'b1;
      AveragePower_Valid <= 0;
    end
  end else begin
    AveragePower_Valid <= 0;
  end
end
//------------------------------------------------------------------------------

wire [7:0]Output;
wire      OutputValid;

LogScale LogScale_Inst(
  .ipClk  (ipClk  ),
  .ipReset(ipReset),

  .ipInput(AveragePower),
  .ipValid(AveragePower_Valid),

  .opOutput(Output),
  .opValid (OutputValid)
);

always @(posedge ipClk) begin
  if(OutputValid) opOutput <= Output;
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

