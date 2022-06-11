module Control_TB;

reg [31:0] opWriteMemory;
reg ipClk;
reg opTx;
UART_PACKET ipTxStream;

initial begin
  opWriteMemory <=31'bz;
  ipClk <= 0;
  ipTxPacket.Valid <=1;
  ipTxStream.SoP <= 1;
  ipTxStream.Eop <= 0;
  ipTxStream.Data <= 8'h55;
end

always #10 ipClk = ~ipClk;

always @(negedge ipClk) begin
  ipTxStream.Valid <= 0;
end

always @(posedge) begin
  //create 4 packets that will test the input
  for (int i=0; i<4; i++) begin
    ipTxStream.Data <= i;
    ipTxStream.Valid <= 1;
  end

end

Control DUT(
  .ipClk(ipClk),
  .opWriteMemory(opWriteMemory),
  .opTx(opTx),
  .ipTxStream(ipTxStream)
);

endmodule //Control_TB