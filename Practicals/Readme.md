# Practicals

This folder contains the practical descriptions for the course.  The intention
is that participants spend time after the course to work on the practicals,
rather than try and finish them all during the course.

This said, the absolute fastest intended schedule is presented below.  The
schedule is limited by the lecture content.

- EEE5117Z:
    - Day 1: Getting Started and Simulation
    - Day 2: UART JTAG and Debugging
    - Day 3: Registers and Data Stream
- EEE5118Z:  
    - Day 4: Arbitration and NCO and DDC
    - Day 5: IIR Filter and Spectrum Analyser
    - Day 6: External FIFO and FIR Filter

## Practicals won't fit onto the Brevia2

From practical 10 onwards, you'll find that the circuit won't fit onto the 
LatticeXP2 Brevia2 Development Kit.  There are sufficient registers, 
multipliers and RAM blocks, but not enough logic elements for all the required 
combinational logic.

If / when you get hold of a larger development kit, such as a 
[DE10-Lite](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=1021),
you'll be able to relatively easily port the design to that kit.  You can buy a
[TTL USB UART](https://www.robotics.org.za/W7965) if the board does not have 
one built-in, and to modify the RAM and ROM blocks to the new vendor is 
relatively easy.
