# FIR Filter

- [Design](#design)
- [Implementation](#implementation)
- [Testing](#testing)

## Design

Design the FIR filter in Matlab / Octave / Python.  Assume a 2048-point filter
with a sub-sampling rate of 256.  The purpose of the filter is to antialiase 
the sub-sampling, so design the coefficients accordingly.

## Implementation

Implement and simulate the FIR filter.  You only need to implement one real
filter, even though the data is complex.  You will create two instances of the 
implementation.

The filter should run on the 50&nbsp;MHz clock, and take an input sampling 
rate of 12.5&nbsp;MSps from the complex mixer.  Every incoming sample should 
therefore update one of 8 running sums, which implies that you have to perform 
eight multiplications per sample, or two per clock cycle per channel.

You should at this point have four 18x18&nbsp;bit multipliers left, which implies 
two per channel.  You should therefore be doing a multiplication every clock cycle.

You should also have 7 memory blocks left.  From the 9 available, you should
be using one for the log scale LUT in the energy counter, and another for the 
Sine LUT in the NCO.  The streaming has been moved to external RAM, so should
not use any of the internal blocks.

Every clock cycle, you need to feed the two multipliers with two 18-bit 
coefficients each.  You can use both ports of a dual-port RAM block, which 
implies you'll need 2 blocks to implement the 2048x 18-bit coefficients.  You
can feed both channels from the same RAM block, so you only need one instance 
of the coefficients LUT.

## Testing

The 128&nbsp;kiB external RAM can only hold 65&nbsp;536&nbsp;samples.  When 
injecting at 12.5&nbsp;MSps that is just over 5&nbsp;ms worth of data.

This is not sufficient for a proper test of the system.  The easiest solution
is to inject periodic data.  Load data in to the external SRAM that can be
looped by the FPGA and therefore injected continuously until the user ends the 
test.

