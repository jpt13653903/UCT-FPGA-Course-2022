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

import numpy as np
import matplotlib.pyplot as plt
#-------------------------------------------------------------------------------

N = 2048

with open('LogScaleLUT.mem', 'w', newline='\n') as File:
    with open('LogScaleLUT_Emulator.v', 'w', newline='\n') as Emulator:
        File.write( '// Generated from LogScaleLUT.py\n')
        File.write( '\n')
        File.write( '// The top 5 bits indicate how many leading zeros there are\n')
        File.write( '// This is followed by an implicit 1\n')
        File.write( '// The bottom 6 bits represent the next bits in the word\n')
        File.write( '\n')
        File.write( '// The output scales 0 => -50 dB_fs and 255 => 0 dB_fs\n')
        File.write( '\n')
        File.write( '#Format=Hex\n')
        File.write(f'#Depth={N}\n')
        File.write( '#Width=8\n')
        File.write( '#AddrRadix=3\n')
        File.write( '#DataRadix=3\n')
        File.write( '#Data\n')

        Emulator.write( '// Generated from LogScaleLUT.py\n')
        Emulator.write('\n')
        Emulator.write( '// Used to emulate the ROM block\n')
        Emulator.write('\n')
        Emulator.write('module LogScaleLUT (\n')
        Emulator.write('  input            OutClock,\n')
        Emulator.write('  input            Reset,\n')
        Emulator.write('  input            OutClockEn,\n')
        Emulator.write('\n')
        Emulator.write('  input      [10:0]Address,\n')
        Emulator.write('  output reg [ 7:0]Q\n')
        Emulator.write(');\n')
        Emulator.write('\n')
        Emulator.write('always @(posedge OutClock) begin\n')
        Emulator.write('  if(OutClockEn) begin\n')
        Emulator.write('    case(Address)\n')

        for n in range(0, N):
            Zeros  = n // 0x80
            Word   = ((n % 0x80) + 0x80) << (16 - Zeros)
            if(Word > 0):
                dB = 10*log10(Word / 0xFFFFFF)
            else:
                dB = -100
            Output = round((dB+50) / 50 * 0xFF)
            if(Output <= 0): Output = 1

            print(f'{Zeros}\t{Word:06X}\t{dB}\t{Output}')
            plt.plot(log10(Word+0.1), Output, 'go')

            File.write(f'{Output:02X}\n')
            Emulator.write(f"      11'h{n:03X}: Q <= 8'h{Output:02X};\n")

        Emulator.write("\n")
        Emulator.write("      default: Q <= 8'hX;\n")
        Emulator.write("    endcase\n")
        Emulator.write("  end\n")
        Emulator.write("end\n")
        Emulator.write("\n")
        Emulator.write("endmodule\n")
#-------------------------------------------------------------------------------

dB     = 50*(np.arange(0, N)/N - 1)
Word   = 10**(dB / 10) * 0xFFFFFF
Output = np.round((dB+50) / 50 * 0xFF)

plt.plot(np.log10(Word), Output, 'b-')
plt.show()
#-------------------------------------------------------------------------------

