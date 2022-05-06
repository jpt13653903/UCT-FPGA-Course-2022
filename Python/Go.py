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

import serial
import struct
import time
import sys
#-------------------------------------------------------------------------------

ClockTicks = 0x00
Buttons    = 0x01
LEDs       = 0x02
#-------------------------------------------------------------------------------

def Write(s, Address, Data):
    s.write(struct.pack('<BBBBBI', 0x55, 0x01, 0xAA, 0x05, Address, Data))
#-------------------------------------------------------------------------------

def Read(s, Address):
    s.write(struct.pack('<BBBBB', 0x55, 0x00, 0xAA, 0x01, Address))
    return struct.unpack_from('<I', s.read(9), offset=5)[0]
#-------------------------------------------------------------------------------

with serial.Serial(port='COM8', baudrate=115200) as s:
    for n in range(500):
        print(Read(s, Buttons))
        Time = Read(s, ClockTicks)
        Write(s, LEDs, Time >> 23)

        print(Time)
        sys.stdout.flush()
        time.sleep(0.02)
#-------------------------------------------------------------------------------

