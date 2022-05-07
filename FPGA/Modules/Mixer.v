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

module Mixer(
  input ipClk,
  input ipReset,

  input  DATA_STREAM    ipInput,
  input  COMPLEX_STREAM ipNCO,
  output COMPLEX_STREAM opOutput
);
//------------------------------------------------------------------------------

reg              Reset;
reg signed [33:0]Prod;

DATA_STREAM    Input;
COMPLEX_STREAM NCO;

enum { Idle, Mul_Q, Done } State;

always @(posedge ipClk) begin
  Reset <= ipReset;

  if(Reset) begin
    opOutput.I     <=  'hX;
    opOutput.Q     <=  'hX;
    opOutput.Valid <= 1'b0;

    State <= Idle;
  end else begin
    case(State)
      Idle: begin
        opOutput.Valid <= 0;

        Input <= ipInput;
        NCO   <= ipNCO;
        Prod  <= ipInput.Data * ipNCO.I;

        if(ipInput.Valid) State <= Mul_Q;
      end
      //------------------------------------------------------------------------

      Mul_Q: begin
        opOutput.I <= Prod[32:15];
        Prod       <= Input.Data * NCO.Q;
        State      <= Done;
      end
      //------------------------------------------------------------------------

      Done: begin
        opOutput.Q     <= Prod[32:15];
        opOutput.Valid <= 1;
        State          <= Idle;
      end
      //------------------------------------------------------------------------

      default:;
    endcase
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

