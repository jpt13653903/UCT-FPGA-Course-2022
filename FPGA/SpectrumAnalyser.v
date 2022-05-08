/*==============================================================================
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
==============================================================================*/

import Structures::*;
//------------------------------------------------------------------------------

module SpectrumAnalyser(
  input       ipClk,
  input       ipnReset,

  input       ipUART_Rx,
  output      opUART_Tx,

  output      opPWM,
  output      opPWM_2,
  output      opTrigger,

  input  [3:0]ipButtons,
  output [7:0]opLED
);
//------------------------------------------------------------------------------

wire Reset = ~ipnReset;
//------------------------------------------------------------------------------

UART_PACKET UART_TxStream;
wire        UART_TxReady;

UART_PACKET UART_RxStream;

UART_Packets UART_Packets_Inst(
  .ipClk     (ipClk),
  .ipReset   (Reset),

  .ipTxStream(  UART_TxStream),
  .opTxReady (  UART_TxReady ),
  .opTx      (opUART_Tx      ),

  .ipRx      (ipUART_Rx    ),
  .opRxStream(UART_RxStream)
);
//------------------------------------------------------------------------------

UART_PACKET Registers_TxStream;
wire        Registers_TxReady;

UART_PACKET Data_TxStream;
wire        Data_TxReady;

StreamMerge #(32) StreamMerge_Inst(
  .ipClk    ( ipClk),
  .ipReset  ( Reset),

  .ipA_SoP  ( Registers_TxStream.SoP),
  .ipA_EoP  ( Registers_TxStream.EoP),
  .ipA_Data ({Registers_TxStream.Source,
              Registers_TxStream.Destination,
              Registers_TxStream.Length,
              Registers_TxStream.Data}),
  .ipA_Valid( Registers_TxStream.Valid),
  .opA_Ready( Registers_TxReady),

  .ipB_SoP  ( Data_TxStream.SoP),
  .ipB_EoP  ( Data_TxStream.EoP),
  .ipB_Data ({Data_TxStream.Source,
              Data_TxStream.Destination,
              Data_TxStream.Length,
              Data_TxStream.Data}),
  .ipB_Valid( Data_TxStream.Valid),
  .opB_Ready( Data_TxReady),

  .opSoP    ( UART_TxStream.SoP),
  .opEoP    ( UART_TxStream.EoP),
  .opData   ({UART_TxStream.Source,
              UART_TxStream.Destination,
              UART_TxStream.Length,
              UART_TxStream.Data}),
  .opValid  ( UART_TxStream.Valid),
  .ipReady  ( UART_TxReady)
);
//------------------------------------------------------------------------------

wire [ 7:0]Registers_Address;
wire [31:0]Registers_WrData;
wire       Registers_WrEnable;
wire [31:0]Registers_RdData;

RegistersControl RegistersControl_Inst(
  .ipClk     (ipClk),
  .ipReset   (Reset),

  .opTxStream(Registers_TxStream),
  .ipTxReady (Registers_TxReady ),

  .ipRxStream(UART_RxStream),

  .opAddress (Registers_Address ),
  .opWrData  (Registers_WrData  ),
  .opWrEnable(Registers_WrEnable),
  .ipRdData  (Registers_RdData  )
);
//------------------------------------------------------------------------------

RD_REGISTERS RdRegisters;
WR_REGISTERS WrRegisters;

Registers Registers_Inst(
  .ipClk        (ipClk),
  .ipReset      (Reset),

  .ipRdRegisters(RdRegisters),
  .opWrRegisters(WrRegisters),

  .ipAddress    (Registers_Address ),
  .ipWrData     (Registers_WrData  ),
  .ipWrEnable   (Registers_WrEnable),
  .opRdData     (Registers_RdData  )
);
//------------------------------------------------------------------------------

always @(posedge ipClk) begin
  if(Reset) RdRegisters.ClockTicks <= 0;
  else      RdRegisters.ClockTicks <= RdRegisters.ClockTicks + 1;
end
//------------------------------------------------------------------------------

DATA_STREAM DataStream;

ReceiveStream ReceiveStream_Inst(
  .ipClk       (ipClk),
  .ipReset     (Reset),

  .opFIFO_Space(RdRegisters.FIFO_Space),
  .ipRxStream  (UART_RxStream),

  .opTxStream  (Data_TxStream),
  .ipTxReady   (Data_TxReady ),

  .opData      (DataStream)
);
//------------------------------------------------------------------------------

TimingGenerator TimingGenerator_Inst(
  .ipClk          (ipClk),
  .ipClkEnable    (DataStream.Valid),
  .ipReset        (Reset),

  .ipWrRegisters  (WrRegisters),

  .opNCO_Frequency(RdRegisters.NCO),
  .opTrigger      (opTrigger)
);
//------------------------------------------------------------------------------

COMPLEX_STREAM NCO_Output;

NCO NCO_Inst(
  .ipClk      (ipClk),
  .ipReset    (Reset),

  .ipFrequency(RdRegisters.NCO),
  .opOutput   (NCO_Output)
);
//------------------------------------------------------------------------------

COMPLEX_STREAM Mixer_Output;

Mixer Mixer_Inst(
  .ipClk   (ipClk),

  .ipInput (DataStream),
  .ipNCO   (NCO_Output),
  .opOutput(Mixer_Output)
);
//------------------------------------------------------------------------------

COMPLEX_STREAM IIR_Filter_Output;

IIR_Filter IIR_Filter_Inst(
  .ipClk  (ipClk),
  .ipReset(Reset),

  .ipA(WrRegisters.IIR_A),
  .ipB(WrRegisters.IIR_B),
  .ipC(WrRegisters.IIR_C),

  .ipInput (Mixer_Output     ),
  .opOutput(IIR_Filter_Output)
);
//------------------------------------------------------------------------------

wire [7:0]EnergyCounter_Output;

EnergyCounter EnergyCounter_Inst(
  .ipClk  (ipClk),
  .ipReset(Reset),

  .ipWindowSize(WrRegisters.WindowSize),

  .ipInput (IIR_Filter_Output),
  .opOutput(EnergyCounter_Output)
);
//------------------------------------------------------------------------------

PWM PWM_Inst(
  .ipClk      (ipClk),
  .ipDutyCycle({~EnergyCounter_Output[7], EnergyCounter_Output[6:0]}),
  // .ipDutyCycle({~IIR_Filter_Output.I[17], IIR_Filter_Output.I[16:10]}),
  .opOutput   (opPWM)
);
assign opPWM_2 = opPWM;
//------------------------------------------------------------------------------

assign RdRegisters.Buttons = ~ipButtons;
assign opLED = ~WrRegisters.LEDs;
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

