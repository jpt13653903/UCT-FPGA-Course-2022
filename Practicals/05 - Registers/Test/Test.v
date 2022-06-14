module Test #(parameter BLOCK_WIDTH = 32) (
  input ipClk,
  input ipReset,
  input ipRx,
  output opTx
);

  reg opTxReady;
  reg [7:0] ipTxAddress; 
  reg [7:0] ipRxAddress;
  reg opTxWrEnable;
  UART_PACKET opRxStream;
  UART_PACKET ipTxStream;

  RD_REGISTERS readRegisters;
  WR_REGISTERS opWrRegisters;

  //need memory to communicate read and write
  reg [BLOCK_WIDTH -1:0] ipWrData;
  reg [BLOCK_WIDTH -1:0] localReadMemory;
  reg opTxWrEnable;


  TransmitController txController(
    .ipClk(ipClk),
    .ipReset(ipReset),
    .opWrRegisters(opWrRegisters),
    .opAddress(ipTxAddress), // this will be input to the Registers module, taken from incoming stream
    .opWrData(ipWrData),// data from the packet that will be input to the registers module
    .ipTxReady(opTxReady), // will use this to gate on the ready of the packet module
    .ipTxStream(ipTxStream),
    .opTxWrEnable(opTxWrEnable)
  );

  RxController rxController(
    .ipClk(ipClk),
    .ipReset(ipReset),
    .ipRdRegisters(ipRdRegisters),
    .opRdData(opRdData),
    .ipAddress(ipRxAddress),
    .opRxStream(opRxStream),
  );
  

  Registers registers(
    .ipClk(ipClk),
    .ipReset(ipReset),
    .ipRdRegisters(readRegisters),
    .opWrRegisters(opWrRegisters),
    .ipAddress(ipAddress), 
    .ipWrData(ipWrData),
    .ipWrEnable(opTxWrEnable),
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