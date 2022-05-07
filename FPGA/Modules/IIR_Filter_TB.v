/*==============================================================================
Copyright (C) John-Philip Taylor
jpt13653903@gmail.com

This file is part of a library

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

// Typical simulation time: 1 second
//------------------------------------------------------------------------------

`timescale 1ns/1ns
//------------------------------------------------------------------------------

import Structures::*;
//------------------------------------------------------------------------------

module IIR_Filter_TB;
//------------------------------------------------------------------------------

reg ipClk = 0;
always #10 ipClk <= ~ipClk;
//------------------------------------------------------------------------------

reg ipReset = 1;
initial begin
  @(posedge ipClk);
  @(posedge ipClk);
  @(posedge ipClk);
  ipReset <= 0;
end
//------------------------------------------------------------------------------

COMPLEX_STREAM ipInput;
reg [2:0]ipFrequencySelect; // 1 -> 4 => 10, 100, 1k and 10k; 0 => bypass

integer n;
integer f;
integer length;

initial begin
  ipInput.Valid = 0;

  @(negedge ipReset);
  @(posedge ipClk);
  @(posedge ipClk);
  @(posedge ipClk);

  forever begin
    for(f = 5; f > 0; f--) begin
      ipFrequencySelect = f;
      case(f)
        1: length = 10000;
        2: length = 1000;
        3: length = 100;
        4: length = 10;
        default: length = 10;
      endcase

      ipInput.I = 18'h00000;
      ipInput.Q = 18'h1FFFF;
      for(n = 0; n < length; n++) begin
        @(posedge ipClk);
        ipInput.Valid = 1;
        @(posedge ipClk);
        ipInput.Valid = 0;
        #22636;
      end

      ipInput.I = 18'h1FFFF;
      ipInput.Q = 18'h00000;
      for(n = 0; n < length; n++) begin
        @(posedge ipClk);
        ipInput.Valid = 1;
        @(posedge ipClk);
        ipInput.Valid = 0;
        #22636;
      end

      ipInput.I = 18'h00000;
      ipInput.Q = 18'h20000;
      for(n = 0; n < length; n++) begin
        @(posedge ipClk);
        ipInput.Valid = 1;
        @(posedge ipClk);
        ipInput.Valid = 0;
        #22636;
      end

      ipInput.I = 18'h20000;
      ipInput.Q = 18'h00000;
      for(n = 0; n < length; n++) begin
        @(posedge ipClk);
        ipInput.Valid = 1;
        @(posedge ipClk);
        ipInput.Valid = 0;
        #22636;
      end
    end
  end
end
//------------------------------------------------------------------------------

// Make these full-scale [-2, 2), so that the equation becomes y = A x + B y_1 - C y_2
reg signed [1:-30]ipA;
reg signed [1:-30]ipB;
reg signed [1:-30]ipC;

always @(*) begin
  case(ipFrequencySelect)
    3'd1: begin // 10 Hz
      ipA = 32'd2_175;
      ipB = 32'd2_145_320_156;
      ipC = 32'd1_071_580_507;
    end

    3'd2: begin // 100 Hz
      ipA = 32'd213_615;
      ipB = 32'd2_125_852_990;
      ipC = 32'd1_052_324_781;
    end

    3'd3: begin // 1 kHz
      ipA = 32'd17_839_621;
      ipB = 32'd1_934_728_551;
      ipC = 32'd878_826_348;
    end

    3'd4: begin // 10 kHz
      ipA = 32'd432_050_169;
      ipB = 32'd854_530_857;
      ipC = 32'd212_839_202;
    end

    default: begin // Pass-through
      ipA = 32'h4000_0000;
      ipB = 32'h0;
      ipC = 32'h0;
    end
  endcase
end
//------------------------------------------------------------------------------

COMPLEX_STREAM opOutput;

IIR_Filter DUT(
  .ipClk  (ipClk  ),
  .ipReset(ipReset),

  .ipA    (ipA),
  .ipB    (ipB),
  .ipC    (ipC),

  .ipInput (ipInput ),
  .opOutput(opOutput)
);
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

