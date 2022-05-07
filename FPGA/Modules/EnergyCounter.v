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

reg       Reset;
reg [31:0]Count;
reg [ 4:0]ShiftCount;

reg [30:0]N;
reg [67:0]Sum;
reg [23:0]Power;
reg       Power_Valid;

reg [35:0]Prod;

COMPLEX_STREAM Input;

enum { Idle, Sum_I, Sum_Q, Shift } State;

always @(posedge ipClk) begin
  Reset <= ipReset;

  if(Reset) begin
    N           <= 0;
    Sum         <= 0;
    Count       <= 0;
    ShiftCount  <= 'hX;

    State       <= Idle;
    Power_Valid <= 0;
  //----------------------------------------------------------------------------

  end else begin
    case(State)
      Idle: begin
        Input       <= ipInput;
        Prod        <= ipInput.I * ipInput.I;
        Power_Valid <= 0;
        ShiftCount  <= ipWindowSize;

        if(ipInput.Valid) State <= Sum_I;
      end
      //------------------------------------------------------------------------

      Sum_I: begin
        Sum   <= Sum + Prod;
        Prod  <= Input.Q * Input.Q;
        State <= Sum_Q;
      end
      //------------------------------------------------------------------------

      Sum_Q: begin
        Sum <= Sum + Prod;

        if(Count == N) begin
          N     <= 0;
          Count <= 0;
          State <= Shift;

        end else begin
          Count <= Count + 1'b1;
          State <= Idle;
        end
      end
      //------------------------------------------------------------------------

      Shift: begin
        if(|ShiftCount) begin
          N          <= {N[29:0], 1'b1};
          Sum        <= {1'b0, Sum[67:1]};
          ShiftCount <= ShiftCount - 1;

        end else begin
          if(|Sum[36:34]) Power <= ~24'd0;
          else            Power <= Sum[33:10];
          Power_Valid <= 1;
          Sum         <= 0;
          State       <= Idle;
        end
      end
      //------------------------------------------------------------------------

      default:;
    endcase
  end
end
//------------------------------------------------------------------------------

wire [7:0]Output;
wire      OutputValid;

LogScale LogScale_Inst(
  .ipClk  (ipClk  ),
  .ipReset(ipReset),

  .ipInput(Power),
  .ipValid(Power_Valid),

  .opOutput(Output),
  .opValid (OutputValid)
);

always @(posedge ipClk) begin
  if(OutputValid) opOutput <= Output;
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

