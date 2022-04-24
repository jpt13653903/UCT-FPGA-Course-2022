# JTAG Debugging

- [Inserter](#inserter)
- [Analyser](#analyser)

--------------------------------------------------------------------------------

## Inserter

With the latest project open, open the `Reveal Inserter` tool.

![Open Reveal Inserter](01_Inserter/01_OpenRevealInserter.png)

Drag and drop the signals you want to inspect.  Also set up the
`Sample Clock`, `Buffer Depth`, `Sample Enable`, etc.

![Setup Signals](01_Inserter/02_SetupSignals.png)

Switch to the `Trigger Setup Setup` tab and set up the trigger.

![Setup Trigger](01_Inserter/03_SetupTrigger.png)

Click the `Insert Debug` button.

![Insert Debug](01_Inserter/04_InsertDebug.png)

Click `Ok` to add the logic analyser core to the design.

![Activate Reveal](01_Inserter/05_ActivateReveal.png)

Choose a convenient file name.

![Choose Filename](01_Inserter/06_ChooseFilename.png)

--------------------------------------------------------------------------------

## Analyser

After the analyser core has been inserted into the design, recompile.

![Recompile](02_Analyser/01_Recompile.png)

Then program the FPGA.

![Program](02_Analyser/02_Program.png)

After programming is complete, open the `Reveal Analyzer` tool.

![Open Reveal Analyser](02_Analyser/03_OpenRevealAnalyser.png)

Choose a convenient file name, set the USB device correctly, auto-detect the 
USB port, select the `.xcf` used to program the FPGA, `Scan` for the
`Debug device` and add the `.rvl` file created by the `Reveal Inserter` tool.

![Setup Analyser](02_Analyser/04_SetupAnalyser.png)

Switch to the `LA Waveform` tab and click `Run`.

![Run](02_Analyser/05_Run.png)

If you followed this example, you now need to use the serial terminal to send 
a bunch of characters to the UART.  After 32 characters has been captured, the 
analyser will display the result.

You can now set the `Bus Radix` to something more readable.

![Set Bus Radix](02_Analyser/06_SetBusRadix.png)

Make it `Hex`.

![Set to Hex](02_Analyser/07_SetToHex.png)

The characters received by the UART module will now be displayed.

![View Signal](02_Analyser/08_ViewSignal.png)

--------------------------------------------------------------------------------

