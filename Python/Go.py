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
import time
import sys
#-------------------------------------------------------------------------------

AudioFile = 'MyMusicFile.wav'
#-------------------------------------------------------------------------------

ClockTicks      = 0x00
Buttons         = 0x01
LEDs            = 0x02
FIFO_Space      = 0x03
NCO             = 0x04
FrequencySelect = 0x05
#-------------------------------------------------------------------------------

def AudioGenerator(AudioFile):
    with audioread.audio_open(AudioFile) as Audio:
        print(Audio.channels, Audio.samplerate, Audio.duration)
        sys.stdout.flush()
        N = 0
        for Buffer in Audio:
            Buffer = [127 for n in Buffer] # Near full-scale (used for testing)
            yield Buffer

Buffer = AudioGenerator(AudioFile)
#-------------------------------------------------------------------------------

def Write(UART, Address, Data):
    UART.write(struct.pack('<BBBBBI', 0x55, 0x01, 0xAA, 0x05, Address, Data))
#-------------------------------------------------------------------------------

def Read(UART, Address):
    UART.write(struct.pack('<BBBBB', 0x55, 0x00, 0xAA, 0x01, Address))

def onReadResponse(Data):
    Address = Data[0]
    Data    = struct.unpack_from('<I', Data, offset=1)[0]
    match Address:
        case 0x03: # FIFO_Space
            Write(UART, LEDs, 256-(Data >> 5))
        case _:
            pass
    return True
#-------------------------------------------------------------------------------

def onAudioFlowControl(UART, Data):
    if(Data[0] == 4):
        Space = 8192 # Timeout, so send a full queue
        print('Received stream timeout')
        sys.stdout.flush()
    else:
        Space = 2048 # Normal ack, so send one packet

    TotalSent = 0
    while(TotalSent < Space):
        try:
            Packet = next(Buffer)
        except StopIteration:
            return False

        Size = len(Packet)
        Sent = 0

        while(Size > 0):
            if(Size >= 256):
                UART.write(struct.pack('<BBBB256B', 0x55, 0x10, 0x10, 0x00, *Packet[Sent:(Sent+256)]))
                Size -= 256
                Sent += 256
            else:
                UART.write(struct.pack(f'<BBBB{Size}B', 0x55, 0x10, 0x10, 0x00, *Packet[Sent:(Sent+Size)]))
                Size  = 0
                Sent += Size
        TotalSent += Sent
    Read(UART, FIFO_Space)
    return True
#-------------------------------------------------------------------------------

def GetPacket(UART):
    while(UART.read(1) != b'\x55'): pass
    Header = UART.read(3)
    Data   = UART.read(Header[2])

    match Header[1]: # Source
        case 0x00: # Read response
            return onReadResponse(Data)
        case 0x01: # Write response
            return True
        case 0x10: # Audio stream flow control
            return onAudioFlowControl(UART, Data)
        case _:
            return True
#-------------------------------------------------------------------------------

with serial.Serial(port='COM8', baudrate=3000000) as UART:
    Write(UART, NCO, round(1000 * (2**32/50e6)))
    Write(UART, FrequencySelect, 3)

    while(GetPacket(UART)): pass
    Write(UART, LEDs, 0)
#-------------------------------------------------------------------------------

