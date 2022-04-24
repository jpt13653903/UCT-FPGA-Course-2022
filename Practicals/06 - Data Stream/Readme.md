# Data Stream

- [The Data Stream](#the-data-stream)
- [PWM Output](#pwm-output)

For this practical, implement a data stream and pulse-width modulation output.

## The Data Stream

Use a spare destination port on the UART interface to implement a data 
stream.  One way to do this is to use a FIFO queue for flow control, and 
expose a `FIFO_Length` register that the PC can read.  The PC then sends the 
next packet only when there is sufficient space in the queue to receive it.

You can use Python to open a sound file and stream the contents to the
FPGA.  You could, for example, convert the file to WAV format and then use:

```Python
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
# TODO: Add registers to control the stream
#-------------------------------------------------------------------------------

# TODO: Reuse the "Read" and "Write" functions from previous practicals
#-------------------------------------------------------------------------------

def Stream(UART, Buffer):
    # TODO: Stream "Buffer" to the FPGA, but only when
    #       the FPGA has space to accept it.
#-------------------------------------------------------------------------------

with audioread.audio_open(AudioFile) as Audio:
    print(Audio.channels, Audio.samplerate, Audio.duration)

    with serial.Serial(port='COM4', baudrate=3000000) as UART:
        for Buffer in Audio:
            Stream(UART, Buffer)
#-------------------------------------------------------------------------------
```

In order to stream 16-bit mono audio at 44100&nbsp;kSps, in addition
to the register control, you need to increase your UART Baud rate to
at least 1&nbsp;MBd.  Use 3&nbsp;MBd to be safe.

## PWM Output

Implement a module that receives a steady stream from the data stream module 
and outputs a PWM signal that you can use to drive a small earphone.

Remember that the output of FPGA pins are either 0&nbsp;or 3.3&nbsp;V, which 
implies that the PWM stream will include a DC offset.  Remove the offset with 
a sufficiently large external capacitor.

Furthermore, make sure that you do not overdrive the FPGA pin.  Keep the 
output current below 5&nbsp;mA peak.  Something like a 470&nbsp;Ω in series
with 47&nbsp;μF capacitor should work quite nicely.

