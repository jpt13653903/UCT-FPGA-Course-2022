# Getting Started

- [IDE Setup](#ide-setup)
- [Create Project](#create-project)
- [New Source File](#new-source-file)
- [Compiler Settings](#compiler-settings)
- [Pin Mapping](#pin-mapping)
- [UART Setup](#uart-setup)
- [Programming](#programming)
- [Design Constraints](#design-constraints)
- [Timing Errors](#timing-errors)
- [Project Files](#project-files)

--------------------------------------------------------------------------------

## IDE Setup

After installing the
[Lattice Diamond](https://www.latticesemi.com/en/Products/DesignSoftwareAndIP/FPGAandLDS/LatticeDiamond)
IDE, you'll need to
[generate a license](https://www.latticesemi.com/Support/Licensing/DiamondAndiCEcube2SoftwareLicensing/DiamondFree)
and set up the environment variable.

![License Setup](01_IDE_Setup/01_LicenseSetup.png)

Once the license is set up, you can start Diamond from the Start menu.

![Start Diamond](01_IDE_Setup/02_StartDiamond.png)

If you'd like to change the default text editor, go to `Tools`, `Options`.

![Tools Options](01_IDE_Setup/03_Tools_Options.png)

You can then add a program to various file types in the `File Associations` section.

![Add Program](01_IDE_Setup/04_AddProgram.png)

After setting up the program, copy the `External Program` to the clipboard.

![Choose Text Editor](01_IDE_Setup/05_ChooseTextEditor.png)

You can now paste that to all the other file extensions you want to change.

![Change All](01_IDE_Setup/06_ChangeAll.png)

--------------------------------------------------------------------------------

## Create Project

From the `Start Page`, select `New...`.

![New Project](02_CreateProject/01_NewProject.png)

Then click `Next`.

![Create Project](02_CreateProject/02_CreateProject.png)

Choose a convenient place for your project and give it a name.

![Counter](02_CreateProject/03_Counter.png)

We don't want to add existing files at this point: there aren't any.

![No Files](02_CreateProject/04_NoFiles.png)

Read the device code from the top of the IC and select the correct part.

![Correct FPGA](02_CreateProject/05_CorrectFPGA.png)

Choose `Synplify Pro` as the compiler.  `Lattice LSE` does not support SystemVerilog.

![Synplify Pro](02_CreateProject/06_SynplifyPro.png)

Review the project information and click `Finish`.

![Project Info](02_CreateProject/07_ProjectInfo.png)

--------------------------------------------------------------------------------

## Project Files

A short-list of important files (i.e. files you might want to keep in Git) include:

Extention | Type                  | Description
--------- | ----                  | -----------
`.ldf`    | Lattice Diamond File  | The main project file
`.ini`    | Initialisation        | IDE-specific settings, like build chain selections
`.sty`    | Strategy              | Compiler settings
`.lpf`    | Logic Preference File | IO standards, pin assignments, etc.
`.fdc`    | Design Constraints    | Synopsis design constraints
`.rvl`    | Reveal                | Reveal inserter
`.rva`    | Reveal                | Reveal analyser
`.rvs`    | Reveal                | Reveal settings
`.v`      | Verilog               | Verilog or SystemVerilog source
`.sv`     | SystemVerilog         | SystemVerilog source
`.vhd`    | VHDL                  | VHDL source
`.xcf`    | Configuration File    | Programming project file
`.jed`    | JEDEC                 | Implementation binary

A more comprehensive list can be found in Table 1 of the 
[Lattice Diamond User Guide](https://www.latticesemi.com/view_document?document_id=53077)

A typical `.gitignore` might therefore look as follows:

```
.vs
.vscode
*.swp
*.bak
~*

*_tcr.dir
*.ccl
*.xml
*.tpf

*.svf
*.trc

impl1/*

!impl1/*.xcf
!impl1/*.jed
```

--------------------------------------------------------------------------------

## New Source File

Once the project has been created, create a new source file.

![New File](03_NewSourceFile/01_NewFile.png)

Create a conveniently-named Verilog file (or VHDL if you so prefer).

![Verilog File](03_NewSourceFile/02_VerilogFile.png)

Implement a module that makes the LEDs flash.

![Count LEDs](03_NewSourceFile/03_CountLEDs.png)

--------------------------------------------------------------------------------

## Compiler Settings

There are a few compiler settings you want to change at this point.

![Synplify Settings](04_CompilerSettings/01_SynplifySettings.png)

Set the VHDL version to 2008 (in case you want to implement modules in VHDL).

![VHDL 2008](04_CompilerSettings/02_VHDL_2008.png)

Also make sure that the `Map Trace` tool warns you against unconstrained paths.

![Map Trace Settings](04_CompilerSettings/03_MapTraceSettings.png)

Then go to the `Property Pages`.

![Property Pages](04_CompilerSettings/04_PropertyPages.png)

And set the Verilog version to `SystemVerilog`.

![System Verilog](04_CompilerSettings/05_SystemVerilog.png)

--------------------------------------------------------------------------------

## Pin Mapping

In order to be able to perform pin-mapping, you need to compile first.  You 
might need to select a different tab in order to see the `Process` window.

![Compile Design](05_PinMapping/01_CompileDesign.png)

The compiler assigns random pins.  Do not program this onto your device, 
because you stand a good chance of damaging pins.  Open the `Spreadsheet View`.

![Open Spreadsheet](05_PinMapping/02_OpenSpreadsheet.png)

Consult the
[development kit user guide](https://www.latticesemi.com/view_document?document_id=43735)
to get the pin numbers of the LEDs.

![User Guide Pins](05_PinMapping/03_UserGuidePins.png)

You can find the clock pin in the schematic section.

![Schematic Clock Pin](05_PinMapping/04_SchematicClockPin.png)

The net names make the direction confusing, so consult the clock circuit.

![Clock Circuit](05_PinMapping/05_ClockCircuit.png)

The Lattice FPGAs have weak pull-up resistors on all
[unsused pins](https://www.latticesemi.com/en/Support/AnswerDatabase/1/0/3/1033)
so you do not need to explicitly drive the `XIN` net to enable the clock.

In the `Spreadsheet View`, assign the pins.

![Assign Pins](05_PinMapping/06_AssignPins.png)

Consult the schematic section of the
[user guide](https://www.latticesemi.com/view_document?document_id=43735)
to see that all banks are set up as 3.3&nbsp;V&nbsp;CMOS.

![3V3 Banks](05_PinMapping/07_3V3_Banks.png)

Before you can set the pin IO standards accordingly, you need to recompile the design.

![Rerun All](05_PinMapping/08_RerunAll.png)

You can now use the right-click menu to set multiple pins at once.

![Set To 3V3 CMOS](05_PinMapping/09_SetTo3V3_CMOS.png)

Open the `.lpf` in a text editor.

![Open Constraints File](05_PinMapping/10_OpenConstraintsFile.png)

You'll see that all the allocations you've just done are simple text lines in 
the `.lpf` file.  You can edit this file directly, without using the GUI, 
which is very convenient when you are using Excel, Python or some other tool 
to auto-generate large numbers of pin assignments.

![Text File Constraints](05_PinMapping/11_TextFileConstraints.png)

--------------------------------------------------------------------------------

## UART Setup

Consult the schematic section of the
[user guide](https://www.latticesemi.com/view_document?document_id=43735)
to see which bus of the FTDI IC drives the UART.  In this case, it is
port&nbsp;B.  Also note that port&nbsp;A is the JTAG.

![FTDI Ports](06_UART_Setup/01_FTDI_Ports.png)

Plug the development board into your computer's USB and open `Device Manager`.

![Open Device Manager](06_UART_Setup/02_OpenDeviceManager.png)

Edit the properties of port&nbsp;B of the `USB Serial Converter`.

![Port B Properties](06_UART_Setup/03_PortB_Properties.png)

Enable the virtual COMM port.

![Enable VCP](06_UART_Setup/04_EnableVCP.png)

Plug the development board out and in again.  This will load
the COMM port.  Note the port number.

![Note COM Port](06_UART_Setup/05_NoteCOM_Port.png)

If you have board that has been pre-loaded with
[the example design](https://www.latticesemi.com/view_document?document_id=37224),
open PuTTY (or some other serial terminal of your choice).

![Open PuTTY](06_UART_Setup/06_OpenPuTTY.png)

Set up the COMM port to use a Baud rate of 115200.

![Set Up COMM Port](06_UART_Setup/07_SetUpCOMM_Port.png)

Open the port and press `0` on the keyboard to display the main menu of the 
development board default firmware.

![PuTTY Menu](06_UART_Setup/08_PuTTY_Menu.png)

--------------------------------------------------------------------------------

## Programming

Open the `Programmer` tool.  Then click on the `Detect Cable` button.

![New Programmer Project](07_Programming/01_NewProgrammerProject.png)

Select port A of the FTDI USB device.

![Detect Cable](07_Programming/02_DetectCable.png)

You should now have a programming project set up and ready to go.  Don't 
program the board yet, because the default setup programs the flash, which is 
non-volatile.

![Program View](07_Programming/03_ProgramView.png)

Instead, double-click on the line to open the settings.  Then set the
`Access mode` to `Static RAM Cell Mode`, which programs the FPGA in a volatile
fashion.  If you'd like to go back to the previous firmware after programming, 
power-cycle the board.

![SRAM Mode](07_Programming/04_SRAM_Mode.png)

Click the `Program` button to program the board.

![Programming](07_Programming/05_Programming.png)

After the programming completes, your LEDs should be counting.

--------------------------------------------------------------------------------

## Design Constraints

Every design must have timing constraints, otherwise the compiler assumes 
whatever it feels like.  Create a new constraints file.

![New Constraints File](08_DesignConstraints/01_NewConstraintsFile.png)

Call it a convenient name, using the `.fdc` file extension.

![Constraints File](08_DesignConstraints/02_ConstraintsFile.png)

Add appropriate design constraints to set the clock frequency and paths that 
should be ignored.  The example below works for most simple projects.

![Basic Constraints](08_DesignConstraints/03_BasicConstraints.png)

--------------------------------------------------------------------------------

## Timing Errors

If you modify the `.fdc` file to specify a much faster clock, the compiler 
will complain that it cannot meet timing requirements.

![Timing Error Box](09_TimingErrors/01_TimingErrorBox.png)

You can view the `Map Trace` report for details.

![Timing Report](09_TimingErrors/02_TimingReport.png)

If you want more specific details, you can open the `Timing Analysis View`, 
which shows detailed information related to the failing path(s).

![Timing Analysis](09_TimingErrors/03_TimingAnalysis.png)

--------------------------------------------------------------------------------

