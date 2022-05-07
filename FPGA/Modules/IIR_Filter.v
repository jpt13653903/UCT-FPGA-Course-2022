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

module IIR_Filter(
  input ipClk,
  input ipReset,

  input signed [1:-30]ipA, // Full-scale [-2, 2)
  input signed [1:-30]ipB,
  input signed [1:-30]ipC,

  input  COMPLEX_STREAM ipInput, // Assumed to be at 44100 kSps
  output COMPLEX_STREAM opOutput
);
//------------------------------------------------------------------------------

reg Reset;

reg signed [0:-17]x  [0:1];
reg signed [0:-35]y_1[0:1];
reg signed [0:-35]y_2[0:1];

reg signed [2:-47]A_x  [0:1];
reg signed [2:-65]B_y_1[0:1];
reg signed [2:-65]C_y_2[0:1];

reg signed [2:-47]y[0:1];

enum{
  Idle,
  Mul1, Mul2, Mul3, Mul4, Mul5, Mul6,
  Add1, Add2,
  Output
} State;

integer n;

always @(posedge ipClk) begin
  Reset <= ipReset;

  if(Reset) begin
    opOutput.I     <= 'hX;
    opOutput.Q     <= 'hX;
    opOutput.Valid <= 0;

    for(n = 0; n < 2; n++) begin
      x    [n] <= 'hX;
      y_1  [n] <= 0;
      y_2  [n] <= 0;

      A_x  [n] <= 'hX;
      B_y_1[n] <= 'hX;
      C_y_2[n] <= 'hX;

      y    [n] <= 'hX;
    end

    State <= Idle;
  //----------------------------------------------------------------------------

  end else begin
    case(State)
      Idle: begin
        opOutput.Valid <= 0;
        x[0] <= ipInput.I;
        x[1] <= ipInput.Q;

        if(ipInput.Valid) State <= Mul1;
      end
      //------------------------------------------------------------------------

      Mul1: begin
        A_x[0] <= ipA * x[0];
        State  <= Mul2;
      end
      //------------------------------------------------------------------------

      Mul2: begin
        A_x[1] <= ipA * x[1];
        State  <= Mul3;
      end
      //------------------------------------------------------------------------

      Mul3: begin
        B_y_1[0] <= ipB * y_1[0];
        State    <= Mul4;
      end
      //------------------------------------------------------------------------

      Mul4: begin
        B_y_1[1] <= ipB * y_1[1];
        State    <= Mul5;
      end
      //------------------------------------------------------------------------

      Mul5: begin
        C_y_2[0] <= ipC * y_2[0];
        State    <= Mul6;
      end
      //------------------------------------------------------------------------

      Mul6: begin
        C_y_2[1] <= ipC * y_2[1];
        State    <= Add1;
      end
      //------------------------------------------------------------------------

      Add1: begin
        y[0]  <= A_x[0] + B_y_1[0][2:-47];
        y[1]  <= A_x[1] + B_y_1[1][2:-47];
        State <= Add2;
      end
      //------------------------------------------------------------------------

      Add2: begin
        y[0]  <= y[0] - C_y_2[0][2:-47];
        y[1]  <= y[1] - C_y_2[1][2:-47];
        State <= Output;
      end
      //------------------------------------------------------------------------

      Output: begin
        for(n = 0; n < 2; n++) begin
          if(y[n][2]) begin
            if(&y[n][1:0]) y_1[n] <= y[n][0:-35];
            else           y_1[n] <= 36'h8_0000_0000;
          end else begin
            if(|y[n][1:0]) y_1[n] <= 36'h7_FFFF_FFFF;
            else           y_1[n] <= y[n][0:-35];
          end

          y_2[n] <= y_1[n];
        end

        opOutput.I     <= y_1[0][0:-17];
        opOutput.Q     <= y_1[1][0:-17];
        opOutput.Valid <= 1;

        State <= Idle;
      end
      //------------------------------------------------------------------------

      default:;
    endcase
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

