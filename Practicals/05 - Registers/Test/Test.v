module Test #(parameter BLOCK_WIDTH = 32) (
  input ipClk,
  input ipReset,
  input ipRx,
  output opTx
);

  reg opTxReady = 0;
  reg [7:0] operationAddress; 
  UART_PACKET opRxStream;
  UART_PACKET ipTxStream;

  RD_REGISTERS readRegisters;
  WR_REGISTERS writeRegisters;

  //need memory to communicate read and write
  reg [BLOCK_WIDTH -1:0] localWriteMemory;
  reg [BLOCK_WIDTH -1:0] localReadMemory;
  reg ipWrEnable

  Registers registers(
    .ipClk(ipClk),
    .ipReset(ipReset),
    .ipRdRegisters(readRegisters),
    .opWrRegisters(writeRegisters),
    .ipAddress(operationAddress),
    .ipWrData(localWriteMemory),
    .ipWrEnable(ipWrEnable),
    .opRdData(localReadMemory)
  );

  UART_Packets uartPackets(
    .ipClk(ipClk),
    .ipReset(ipReset),
    .ipTxStream(ipTxStream),
    .opTxReady(opTxReady),
    .opTx(opTx),
    .ipRx(ipRx),
    .opRxStream(opRxStream)
  );


endmodule //Test