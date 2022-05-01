`timescale 1ns/1ns // unit/precision
module UART_TB;
//------------------------------------------------------------------------------

reg ipClk = 0;
always #10 ipClk <= ~ipClk;
//------------------------------------------------------------------------------

reg ipReset = 1;
initial begin
  @(posedge ipClk);
  @(posedge ipClk);
  @(posedge ipClk);
  ipReset <= 0;
end
//------------------------------------------------------------------------------

reg  [7:0]ipTxData;
reg       ipTxSend;
wire      opTxBusy;
wire      opTx;

integer TxBit;

initial begin
  ipTxSend = 0;

  @(negedge ipReset);
  @(posedge ipClk);

  while(1) begin
    ipTxData = $urandom_range(0, 255);
    if(opTxBusy) @(negedge opTxBusy);

    assert(opTx == 1) else
      $error("Tx should idle high");

    @(posedge ipClk);
    ipTxSend = 1;

    @(posedge opTxBusy);
    @(posedge ipClk);
    ipTxSend = 0;

    #4340;
    assert(opTx == 0) else
      $error("Expecting start bit");

    for(TxBit = 0; TxBit < 8; TxBit++) begin
      #8681;
      assert(opTx == ipTxData[TxBit]) else
        $error("Incorrect data bit");
    end

    #8681;
    assert(opTx == 1) else
      $error("Expecting stop bit");
  end
end
//------------------------------------------------------------------------------

reg       ipRx;
wire [7:0]opRxData;
wire      opRxValid;

reg  [7:0]RxData;
integer   RxBit;

initial begin
  ipRx = 1;

  @(negedge ipReset);
  @(posedge ipClk);

  while(1) begin
    #($urandom_range(5000, 50000));

    RxData = $urandom_range(0, 255);

    ipRx = 0;
    #8681;
    for(RxBit = 0; RxBit < 8; RxBit++) begin
      ipRx = RxData[RxBit];
      #8681;
    end
    ipRx = 1;

    @(posedge opRxValid);
    #1;
    assert(opRxData == RxData) else
      $error("Rx Data Error");
  end
end
//------------------------------------------------------------------------------

UART DUT(
  .ipClk    (ipClk    ),
  .ipReset  (ipReset  ),
                      
  .ipTxData (ipTxData ),
  .ipTxSend (ipTxSend ),
  .opTxBusy (opTxBusy ),
  .opTx     (opTx     ),
                      
  .ipRx     (ipRx     ),
  .opRxData (opRxData ),
  .opRxValid(opRxValid)
);
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------