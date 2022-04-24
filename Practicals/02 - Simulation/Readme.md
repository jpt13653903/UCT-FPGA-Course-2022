# Simulation

- [IDE Setup](#ide-setup)
- [Create Testbench](#create-testbench)
- [Compile](#compile)
- [Simulate](#simulate)
- [Wave Navigation](#wave-navigation)
- [Scripting](#scripting)
- [Breakpoints](#breakpoints)
- [Resets](#resets)

--------------------------------------------------------------------------------

## IDE Setup

Open the Mentor Modelsim Lattice Edition.

![OpenModelsim](01_IDE_Setup/01_OpenModelsim.png)

After starting Modelsim, first thing to do is change the working folder to 
your working folder.

![ChangeDirectory](01_IDE_Setup/02_ChangeDirectory.png)

It is generally a good idea to have a dedicated `Simulation` folder, separate from where the source files are stored.

![ChooseFolder](01_IDE_Setup/03_ChooseFolder.png)

Open up the `Compile Options` dialogue.

![CompileOptions](01_IDE_Setup/04_CompileOptions.png)

Set the VHDL version to 2008.

![VHDL 2008](01_IDE_Setup/05_VHDL_2008.png)

And the Verilog version to SystemVerilog.

![SystemVerilog](01_IDE_Setup/06_SystemVerilog.png)

--------------------------------------------------------------------------------

## Create Testbench

Create a new Verilog source file, which will become the testbench for the 
`Counter` module.

![CreateFile](02_CreateTestbench/01_CreateFile.png)

Implement a testbench for the `Counter`.  The example below includes a reset 
signal, which will be used later.

![ImplementTestbench](02_CreateTestbench/02_ImplementTestbench.png)

--------------------------------------------------------------------------------

## Compile

Compile the new modules.

![Compile](03_Compile/01_Compile.png)

Choose the `Counter`, along with its testbench.

![ChooseFiles](03_Compile/02_ChooseFiles.png)

Let Modelsim create the `work` library for you.

![CreateWorkLibrary](03_Compile/03_CreateWorkLibrary.png)

If all goes well, the transcript will show that the compile was
successful.  Follow the errors and fix the syntax errors otherwise.

--------------------------------------------------------------------------------

## Simulate

Simulate the test-bench.

![Simulate](04_Simulate/01_Simulate.png)

Drag the signals over to the wave-form viewer and set the radix to `Hexadecimal`.

![AddSignals](04_Simulate/02_AddSignals.png)

Run the simulation for 1 second.

![Run](04_Simulate/03_Run.png)

You'll notice a problem with the LEDs.  The result is `unknown` for the full 
duration of the simulation.

![ProblemWithLEDs](04_Simulate/04_ProblemWithLEDs.png)

The problem is that the `Count` signal is not initialised, so add an initialiser.

![InitCounter](04_Simulate/05_InitCounter.png)

When you make changes to the source, it has to be recompiled.

![Recompile](04_Simulate/06_Recompile.png)

And the simulation must be restarted.

![Restart](04_Simulate/07_Restart.png)

When prompted, restart everything.

![RestartEverything](04_Simulate/08_RestartEverything.png)

You can then run the simulation again.

--------------------------------------------------------------------------------

## Wave Navigation

To zoom in with the mouse, drag with the middle mouse button. Dragging in an 
upwards direction zooms out, whereas dragging in a downwards direction zooms in.

![Zoom](05_WaveNavigation/01_Zoom.png)

You can place a cursor by dragging with the left mouse button.  It generally 
snaps to nearby edges.

![DragCursor](05_WaveNavigation/02_DragCursor.png)

To measure time intervals, start by dragging the marker to the correct
place.  Then lock the existing marker and use the green `+` button to create 
another one. Drag it to the second point.

![MoreCursors](05_WaveNavigation/03_MoreCursors.png)

To set the time scale on the wave-form viewer, right-click on the time-scale and open up the `Grid, Timeline & Cursor Control` dialogue.

![TimelineControl](05_WaveNavigation/04_TimelineControl.png)

Set the time-scale to milliseconds.

![Milliseconds](05_WaveNavigation/05_Milliseconds.png)

All times are now displayed in a convenient unit.

![TimeDeltas](05_WaveNavigation/06_TimeDeltas.png)

--------------------------------------------------------------------------------

## Scripting

Once everything is set up, you can create a script to set up
future sessions. Use the `Save Format` option.

![SaveFormat](06_Scripting/01_SaveFormat.png)

Pick an appropriate file name and location.

![ChooseFileName](06_Scripting/02_ChooseFileName.png)

Edit the generated TCL script to do what you want it to do.  Typically, it should
switch to the work library, compile the source files (in the correct order),
open the simulation, set up the wave-forms and viewer properties and then run
the simulation.  The `Save Format` feature does only the wave-form setup.

![AddCompileAndSimulation](06_Scripting/03_AddCompileAndSimulation.png)

To test the script, close Modelsim completely and then re-open it. Switch 
working folder as before and then "source" the script using the TCL console.

![RunScript](06_Scripting/04_RunScript.png)

--------------------------------------------------------------------------------

## Breakpoints

It is often useful to debug using break-points.  Edit the file in Modelsim.

![EditSource](07_Breakpoints/01_EditSource.png)

Then click the margin to set breakpoints.

![SetBreakpoint](07_Breakpoints/02_SetBreakpoint.png)

When you run the simulation, the process will break at the set point, and you 
can use mouse-hover to obtain the values of variables and signals.

![ReadValue](07_Breakpoints/03_ReadValue.png)

--------------------------------------------------------------------------------

## Resets

Not all FPGAs can initialise registers during initialisation.  It is therefore 
much better to use a dedicated reset signal.  Edit the `Counter` module and 
add a reset.  Remember to hook up the new reset signal in the testbench.

![AddResetSignal](08_Resets/01_AddResetSignal.png)

You can now resimulate the design to see that the reset is working correctly.

![Resimulate](08_Resets/02_Resimulate.png)

Remember to add the new `ipReset` pin to the `.lpf` file before you load it
onto the FPGA.

--------------------------------------------------------------------------------

