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

module LogScale(
  input ipClk,
  input ipReset,

  input  [23:0]ipInput,  // Power signal (i.e. y = 10*log(x) )
  input        ipValid,

  output [ 7:0]opOutput, // 0 => -50 dB_fs; 255 => 0 dB_fs
  output reg   opValid
);
//------------------------------------------------------------------------------

reg  [ 3:0]Zeros;
reg  [23:0]Input;
wire [10:0]Address = Input[23] ? {Zeros, Input[22:16]} : {4'hF, 7'h0};

LogScaleLUT LUT(
  .OutClock  (ipClk   ),
  .Reset     (ipReset ),
  .OutClockEn(1'b1    ),
  .Address   (Address ),
  .Q         (opOutput)
);
//------------------------------------------------------------------------------

reg Reset;

enum{
  Idle,
  CountZeros,
  Done
} State;

always @(posedge ipClk) begin
  Reset <= ipReset;

  if(Reset) begin
    opValid <=  0;

    Zeros   <= 'hX;
    Input   <= 'hX;
  //----------------------------------------------------------------------------

  end else begin
    case(State)
      Idle: begin
        opValid <= 1'b0;
        Zeros   <= 4'd0;
        Input   <= ipInput;

        if(ipValid) begin
          State <= CountZeros;
        end
      end
      //------------------------------------------------------------------------

      CountZeros: begin
        if(Input[23] || (Zeros == 15)) begin
          opValid <= 1'b1;
          State   <= Idle;
        end else begin
          Zeros <= Zeros + 1;
          Input <= {Input[22:0], 1'b0};
        end
      end
      //------------------------------------------------------------------------

      default:;
    endcase
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

