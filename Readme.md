# Practical Memo

This memo presents only one possible solution, and should not be taken as "the"
solution.  There is a Git tag for each practical.

## Practicals won't fit onto the Brevia2

From practical 10 onwards, you'll find that the circuit won't fit onto the 
LatticeXP2 Brevia2 Development Kit.  There are sufficient registers, 
multipliers and RAM blocks, but not enough logic elements for all the required 
combinational logic.

These solutions have been tested in simulation by means of unit-testing, as 
well as on hardware by strategically removing other processing blocks
from the chain.

Also, the solution presented is the complete chain, as if the design fits, but 
when you try to compile it you'll find that the compiler complains that the 
FPGA is too small.  You can view the device usage per module by consulting the 
"Hierarchy" tab after trying to compile, and the Map report also shows useful 
resource usage statistics.

On that note, if you have a successful compile that you've run up to and 
including the "Map Trace" stage, the "Hierarchy" tab gives you a post-map 
resource usage, which is quite useful.  If you compile all the way to a JEDEC 
file, that report goes away for some reason.

Anyway -- If / when you get hold of a larger development kit, such as a 
[DE10-Lite](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=1021),
you'll be able to relatively easily port the design to that kit.  You can buy a
[TTL USB UART](https://www.robotics.org.za/W7965) if the board does not have 
one built-in, and to modify the RAM and ROM blocks to the new vendor is 
relatively easy.

