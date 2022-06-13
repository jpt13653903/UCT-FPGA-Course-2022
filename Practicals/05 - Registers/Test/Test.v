module Test #(parameter BLOCK_WIDTH = 32) (
  input ipClk,
  input ipReset,
  input ipRx,
  output opTx
);

  reg opTxReady = 0;
  reg [7:0] ipAddress; 
  UART_PACKET opRxStream;
  UART_PACKET ipTxStream;

  RD_REGISTERS readRegisters;
  WR_REGISTERS opWrRegisters;

  //need memory to communicate read and write
  reg [BLOCK_WIDTH -1:0] ipWrData;
  reg [BLOCK_WIDTH -1:0] localReadMemory;
  reg ipWrEnable


  TransmitController txController(
    .ipClk(ipClk),
    .ipReset(ipReset),
    .opWrRegisters(opWrRegisters),
    .ipAddress(ipAddress),
    .ipWrData(ipWrData),
    .ipWrEnable(opTxReady),
    .ipTxStream(ipTxStream)
  )
  

  Registers registers(
    .ipClk(ipClk),
    .ipReset(ipReset),
    .ipRdRegisters(readRegisters),
    .opWrRegisters(opWrRegisters),
    .ipAddress(ipAddress),
    .ipWrData(ipWrData),
    .ipWrEnable(opTxReady),
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