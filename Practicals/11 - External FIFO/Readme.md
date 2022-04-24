# External FIFO

- [External Memory](#external-memory)
- [High Speed Injection](#high-speed-injection)

## External Memory

The LatticeXP2 Brevia 2 development kit includes 128 kB external
memory.  Implement a controller that abstracts this external memory
as a 16-bit memory-mapped Avalon interface.

Pay particular attention to the external timing requirements of the memory 
IC.  You'll need to add appropriate design constraints to your project in 
order to make the memory work correctly.  You might even need to use a phase 
locked loop to generate an offset clock so that you can meet both read and 
write timing.

## High Speed Injection

Modify the data injection mechanism to inject data at 12.5 MSps.  A typical 
strategy is to fill the memory from the PC without injecting anything.  When 
the queue is full, the data is then injected into the rest of the chain at 
full rate until the memory is empty, after which the cycle repeats.

