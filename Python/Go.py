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

import audioread
import serial
import struct
import time
import sys
#-------------------------------------------------------------------------------

AudioFile = 'MyMusicFile.wav'
#-------------------------------------------------------------------------------

ClockTicks = 0x00
Buttons    = 0x01
LEDs       = 0x02
FIFO_Space = 0x03

NCO        = 0x10
NCO_Start  = 0x11
NCO_Stop   = 0x12
NCO_Step   = 0x13

IIR_A      = 0x20
IIR_B      = 0x21
IIR_C      = 0x22

WindowSize = 0x30
#-------------------------------------------------------------------------------

def AudioGenerator(AudioFile):
    with audioread.audio_open(AudioFile) as Audio:
        print(f'Audio: {Audio.channels} ch, {Audio.samplerate} Sps, {Audio.duration} sec')
        sys.stdout.flush()
        for Buffer in Audio:
            yield Buffer
#-------------------------------------------------------------------------------

def FullScaleGenerator():
    print('Full scale output')
    sys.stdout.flush()
    N = 1024
    Buffer = [2**15-1 for n in range(N)]
    Buffer = struct.pack('<1024h', *Buffer)
    while(True):
        yield Buffer
#-------------------------------------------------------------------------------

def SquareGenerator():
    print('Square output')
    sys.stdout.flush()
    N = 1024
    Buffer = [2**14 if (n % 16 < 8) else -2**14 for n in range(N)]
    Buffer = struct.pack('<1024h', *Buffer)
    while(True):
        yield Buffer
#-------------------------------------------------------------------------------

# Buffer = AudioGenerator(AudioFile)
# Buffer = FullScaleGenerator()
Buffer = SquareGenerator()
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

def SetFreqSweep(UART, Start, Stop, Time):
    f1 = round(Start * (2**32/50e6))
    f2 = round(Stop  * (2**32/50e6))
    df = round((f2 - f1) / (44100*Time))
    if(df <= 0): df = 1

    print(f'SetFreqSweep({Start}, {Stop}, {Time}): {f1}; {f2}; {df}')

    Write(UART, NCO_Start, f1)
    Write(UART, NCO_Stop , f2)
    Write(UART, NCO_Step , df)
#-------------------------------------------------------------------------------

def SetIIR(UART, f0):
    fs = 44100
    N  = 30
    z  = 1/sqrt(2)

    if(f0 >= fs):
        A = 0x40000000
        B = 0
        C = 0

    else:
        w0 = 2 * pi * f0

        a =   fs**2 + 2*z*w0*fs + w0**2
        b = 2*fs**2 + 2*z*w0*fs
        c =   fs**2

        A = round((2**N / a) * w0**2)
        B = round((2**N / a) * b)
        C = round((2**N / a) * c)

    print(f'SetIIR({f0}): {A}; {B}; {C}')
    
    Write(UART, IIR_A, A)
    Write(UART, IIR_B, B)
    Write(UART, IIR_C, C)
#-------------------------------------------------------------------------------

with serial.Serial(port='COM8', baudrate=3000000) as UART:
    SetIIR      (UART, 100)
    SetFreqSweep(UART, 0, 44100, 10)
    Write(UART, WindowSize, 4)

    while(GetPacket(UART)): pass
    Write(UART, LEDs, 0)
#-------------------------------------------------------------------------------

