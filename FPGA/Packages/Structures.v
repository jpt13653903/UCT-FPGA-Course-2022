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

package Structures;
//------------------------------------------------------------------------------

typedef struct{
  logic [31:0]ClockTicks;
  logic [ 3:0]Buttons;
  logic [12:0]FIFO_Space;

  logic [31:0]NCO;
} RD_REGISTERS;

typedef struct{
  logic [ 7:0]LEDs;

  logic [31:0]NCO_Start;
  logic [31:0]NCO_Stop;
  logic [31:0]NCO_Step;

  logic [31:0]IIR_A;
  logic [31:0]IIR_B;
  logic [31:0]IIR_C;

  logic [ 4:0]WindowSize;
} WR_REGISTERS;
//------------------------------------------------------------------------------

typedef struct{
  logic [7:0]Source;
  logic [7:0]Destination;
  logic [7:0]Length; // 0 => 256

  logic      SoP;
  logic      EoP;
  logic [7:0]Data;
  logic      Valid;
} UART_PACKET;
//------------------------------------------------------------------------------

typedef struct{
  logic signed [15:0]Data;
  logic              Valid;
} DATA_STREAM;
//------------------------------------------------------------------------------

typedef struct{
  logic signed [17:0]I;
  logic signed [17:0]Q;
  logic              Valid;
} COMPLEX_STREAM;
//------------------------------------------------------------------------------

endpackage
//------------------------------------------------------------------------------

