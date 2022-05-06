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

import audioread
import serial
import struct
#-------------------------------------------------------------------------------

AudioFile = 'MyMusicFile.wav'
#-------------------------------------------------------------------------------

ClockTicks = 0x00
Buttons    = 0x01
LEDs       = 0x02
FIFO_Space = 0x03
#-------------------------------------------------------------------------------

def Write(UART, Address, Data):
    UART.write(struct.pack('<BBBBBI', 0x55, 0x01, 0xAA, 0x05, Address, Data))
#-------------------------------------------------------------------------------

def Read(UART, Address):
    UART.write(struct.pack('<BBBBB', 0x55, 0x00, 0xAA, 0x01, Address))
    return struct.unpack_from('<I', UART.read(9), offset=5)[0]
#-------------------------------------------------------------------------------

def Stream(UART, Buffer):
    Size = len(Buffer)
    Sent = 0

    Space = Read(UART, FIFO_Space)
    Write(UART, LEDs, 256-(Space >> 5))
    while(Space < Size): Space = Read(UART, FIFO_Space)

    while(Size > 0):
        if(Size >= 256):
            UART.write(struct.pack('<BBBB256B', 0x55, 0x10, 0xAA, 0x00, *Buffer[Sent:(Sent+256)]))
            Size -= 256
            Sent += 256
        else:
            UART.write(struct.pack(f'<BBBB{Size}B', 0x55, 0x10, 0xAA, 0x00, *Buffer[Sent:(Sent+Size)]))
            Size  = 0
            Sent += Size
#-------------------------------------------------------------------------------

with audioread.audio_open(AudioFile) as Audio:
    print(Audio.channels, Audio.samplerate, Audio.duration)

    with serial.Serial(port='COM8', baudrate=3000000) as UART:
        for Buffer in Audio: Stream(UART, Buffer)
        Write(UART, LEDs, 0)
#-------------------------------------------------------------------------------

