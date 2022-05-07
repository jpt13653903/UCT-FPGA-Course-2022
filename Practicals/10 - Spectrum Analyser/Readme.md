# Spectrum Analyser

- [Energy Counter](#energy-counter)
- [Output](#output)
- [Timing Generator](#timing-generator)

## Energy Counter

Implement the energy counter, as described in the slides.

## Output

Provide a log-scaled output by means of the PWM module.  Scale it such that a 
duty-cycle of 0&nbsp;implies -50&nbsp;dB<sub>fs</sub>, and a duty-cycle of 
1&nbsp;implies 0&nbsp;dB<sub>fs</sub>.

In order to save on memory space, you can define the first 4 bits of the LUT 
address to represent the number of leading zeros, and the remaining bits to 
represent the mantissa (i.e. bits after the leading `1`).  In other words, the 
address can be a simple floating point representation.

## Timing Generator

Implement the timing generator, as described in the slides, and hook up all 
the signals to the correct places in order to build a spectrum analyser.

There are many parameters that can be tuned.  Implement these parameters as
registers so that you can control them from the PC.

