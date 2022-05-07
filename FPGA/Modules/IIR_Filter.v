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

  input [2:0]ipFrequencySelect, // 1 -> 4 => 10, 100, 1k and 10k

  input  COMPLEX_STREAM ipInput, // Assumed to be at 44100 kSps
  output COMPLEX_STREAM opOutput
);
//------------------------------------------------------------------------------

// Make these full-scale [-2, 2), so that the equation becomes y = A x + B y_1 - C y_2
reg signed [1:-32]A;
reg signed [1:-32]B;
reg signed [1:-32]C;

always @(*) begin
  case(ipFrequencySelect)
    3'd1: begin // 10 Hz
      A = 34'd8_701;
      B = 34'd8_581_280_625;
      C = 34'd4_286_322_029;
    end

    3'd2: begin // 100 Hz
      A = 34'd854_461;
      B = 34'd8_503_411_959;
      C = 34'd4_209_299_124;
    end

    3'd3: begin // 1 kHz
      A = 34'd71_358_485;
      B = 34'd7_738_914_205;
      C = 34'd3_515_305_394;
    end

    3'd4: begin // 10 kHz
      A = 34'd1_728_200_677;
      B = 34'd3_418_123_427;
      C = 34'd851_356_808;
    end

    default: begin // Pass-through
      A = 34'h1_0000_0000;
      B = 34'h0;
      C = 34'h0;
    end
  endcase
end
//------------------------------------------------------------------------------

reg Reset;

reg signed [0:-17]x  [0:1];
reg signed [0:-35]y_1[0:1];
reg signed [0:-35]y_2[0:1];

reg signed [2:-49]A_x  [0:1];
reg signed [2:-67]B_y_1[0:1];
reg signed [2:-67]C_y_2[0:1];

reg signed [2:-67]y[0:1];

enum{
  Idle,
  Mul1, Mul2, Mul3, Mul4, Mul5, Mul6,
  Add,
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

        if(ipInput.Valid) begin
          x[0]  <= ipInput.I;
          x[1]  <= ipInput.Q;
          State <= Mul1;
        end
      end
      //------------------------------------------------------------------------

      Mul1: begin
        A_x[0] <= A * x[0];
        State  <= Mul2;
      end
      //------------------------------------------------------------------------

      Mul2: begin
        A_x[1] <= A * x[1];
        State <= Mul3;
      end
      //------------------------------------------------------------------------

      Mul3: begin
        B_y_1[0] <= B * y_1[0];
        State <= Mul4;
      end
      //------------------------------------------------------------------------

      Mul4: begin
        B_y_1[1] <= B * y_1[1];
        State <= Mul5;
      end
      //------------------------------------------------------------------------

      Mul5: begin
        C_y_2[0] <= C * y_2[0];
        State <= Mul6;
      end
      //------------------------------------------------------------------------

      Mul6: begin
        C_y_2[1] <= C * y_2[1];
        State <= Add;
      end
      //------------------------------------------------------------------------

      Add: begin
        y[0] <= {A_x[0], 18'd0} + B_y_1[0] - C_y_2[0];
        y[1] <= {A_x[1], 18'd0} + B_y_1[1] - C_y_2[1];
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

