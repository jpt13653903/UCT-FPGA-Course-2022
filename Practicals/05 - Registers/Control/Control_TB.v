import Structures::*;
`timescale 1ns/1ns;
module Control_TB;
reg [31:0] opWriteMemory;
reg [31:0] ipReadMemory;
reg ipClk;
reg opTx;
reg ipReset;
UART_PACKET ipTxPacket;
UART_PACKET opRxPacket;
reg ipWrEnable;

initial begin
  opWriteMemory <=31'bz;
  ipClk <= 0;
  ipTxPacket.Valid <=1;
  ipTxPacket.SoP <= 1;
  ipTxPacket.EoP <= 0;
  ipTxPacket.Length <=4;
  ipTxPacket.Data <= 8'h55;
  ipTxPacket.Source <= 8'h01;
  ipTxPacket.Destination <= 8'h00;
  ipWrEnable <= 1;
  ipReset <= 1;
end

initial #5 begin
  ipReset <=0;
end

always #10 ipClk = ~ipClk;

always @(negedge ipClk) begin
  
  // ipWrEnable <= 0;
end

always @(posedge ipClk) begin
  //create 4 packets that will test the input
  for (int i=0; i<4; i++) begin
    if(i == 0 ) begin
      ipWrEnable <= 1;
    end else begin
      ipWrEnable <=0;
    end
    ipTxPacket.Data <= i + 1;
    ipTxPacket.Valid <= 1;
    
  end

end

Control DUT(
  .ipClk(ipClk),
  .opWriteMemory(opWriteMemory),
  .ipTxPacket(ipTxPacket),
  .ipWrEnable(ipWrEnable),
  .ipReadMemory(ipReadMemory),
  .ipReset(ipReset),
  .opRxPacket(opRxPacket)
);

endmodule //Control_TB