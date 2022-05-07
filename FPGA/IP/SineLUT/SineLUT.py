"""=============================================================================
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
============================================================================="""

from math import *
#-------------------------------------------------------------------------------

N = 1024

with open('SineLUT.mem', 'w', newline='\n') as File:
    with open('SineLUT_Emulator.v', 'w', newline='\n') as Emulator:
        File.write( '// Generated from SineLUT.py\n')
        File.write( '#Format=Hex\n')
        File.write(f'#Depth={N}\n')
        File.write( '#Width=18\n')
        File.write( '#AddrRadix=3\n')
        File.write( '#DataRadix=3\n')
        File.write( '#Data\n')

        Emulator.write('// Generated from SineLUT.py\n')
        Emulator.write('\n')
        Emulator.write('// Used to emulate the ROM block\n')
        Emulator.write('\n')
        Emulator.write('module SineLUT(\n')
        Emulator.write('  input            ClockA,\n')
        Emulator.write('  input            ResetA,\n')
        Emulator.write('  input            ClockEnA,\n')
        Emulator.write('  input      [ 9:0]AddressA,\n')
        Emulator.write('  input      [17:0]DataInA,\n')
        Emulator.write('  input            WrA,\n')
        Emulator.write('  output reg [17:0]QA,\n')
        Emulator.write('\n')
        Emulator.write('  input            ClockB,\n')
        Emulator.write('  input            ResetB,\n')
        Emulator.write('  input            ClockEnB,\n')
        Emulator.write('  input      [ 9:0]AddressB,\n')
        Emulator.write('  input      [17:0]DataInB,\n')
        Emulator.write('  input            WrB,\n')
        Emulator.write('  output reg [17:0]QB\n')
        Emulator.write(');\n')
        Emulator.write('\n')
        Emulator.write('always @(posedge ClockA) begin\n')
        Emulator.write('  if(ClockEnA) begin\n')
        Emulator.write('    case(AddressA)\n')
        
        for n in range(0, N):
            x = sin(2.0 * pi * (n/N))
            x = round((2**17-1)*x)
            if(x < 0): x += 2**18
            File.write(f'{x:05X}\n')
            Emulator.write(f"      10'h{n:03X}: QA <= 18'h{x:05X};\n")

        Emulator.write('      default:;\n')
        Emulator.write('    endcase\n')
        Emulator.write('  end\n')
        Emulator.write('end\n')
        Emulator.write('\n')
        Emulator.write('always @(posedge ClockB) begin\n')
        Emulator.write('  if(ClockEnB) begin\n')
        Emulator.write('    case(AddressB)\n')
        
        for n in range(0, N):
            x = sin(2.0 * pi * (n/N))
            x = round((2**17-1)*x)
            if(x < 0): x += 2**18
            Emulator.write(f"      10'h{n:03X}: QB <= 18'h{x:05X};\n")

        Emulator.write('      default:;\n')
        Emulator.write('    endcase\n')
        Emulator.write('  end\n')
        Emulator.write('end\n')
        Emulator.write('\n')
        Emulator.write('endmodule\n')
#-------------------------------------------------------------------------------

