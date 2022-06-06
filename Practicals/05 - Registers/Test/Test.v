module Test (
  input ipClk,
  input ipReset,
  input ipRx,
  output opTx
);

  reg opTxReady; 
  UART_PACKET opRxStream;
  UART_PACKET ipTxStream;

  RD_REGISTERS readRegisters;
  WR_REGISTERS writeRegisters;

  // need to generate input and output addresses between 2 interfaces
  //need to generate input and output registers for 2 interfaces


  Registers registers(
    .ipClk(ipClk),
    .ipReset(ipReset),
    .ipRdRegisters(readRegisters),
    .opWrRegisters(writeRegisters),
    .ipAddress(ipTxStream.Destination),
    .ipWrData(ipTxStream.Data),
    .ipWrEnable(opTxReady && ipTxStream.Valid),
    .opRdData(opRxStream.Data)
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