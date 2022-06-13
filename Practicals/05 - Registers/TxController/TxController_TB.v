`timescale 1ns/1ns

import Structures::*;

module TxController_TB;
  reg ipClk = 0;
  reg ipReset = 1;
  reg opTxReady = 1;
  reg [4:0] count = 4'd8;
  reg opTxWrEnable = 0;
  reg [7:0] ipAddress;
  reg [31:0] ipWrData;
  UART_PACKET ipTxPacket;
  
  always #10 begin
    ipClk = ~ipClk;
  end

  initial begin
    #20 ipReset <= 0;
    ipTxPacket.Valid <=1;
    ipTxPacket.SoP <= 1;
    ipTxPacket.EoP <= 0;
    ipTxPacket.Length <= 4;
    ipTxPacket.Data <= count;
    ipTxPacket.Source <= 8'h01;
    ipTxPacket.Destination <= 8'h01;
  end

  always @(posedge ipClk) begin
    ipTxPacket.Data <= count;
  end

  always @(negedge ipClk) begin
    ipTxPacket.Valid <= 0;
    opTxReady <= 0;
    if (count == 0) begin
      $stop;
    end
  end

always @(posedge opTxWrEnable) begin
  count <= count - 1;
end
  
  initial begin
    
    while (count>0) begin
      if(opTxWrEnable && !ipTxPacket.Valid && !opTxReady) begin
        
        ipTxPacket.Valid <= 1;
        opTxReady <= 1;
      end    
    end
  end

  TxController DUT(
    .ipClk(ipClk),
    .ipReset(ipReset),
    .opAddress(ipAddress),
    .opWrData(ipWrData),
    .ipTxReady(opTxReady),
    .ipTxStream(ipTxPacket),
    .opTxWrEnable(opTxWrEnable)
  );

endmodule //TxController_TB