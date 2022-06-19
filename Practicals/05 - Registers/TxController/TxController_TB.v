`timescale 1ns/1ns

import Structures::*;

module TxController_TB;
  reg ipClk = 0;
  reg ipReset = 1'b1;
  reg [4:0] count = 4'd8;
  reg opTxWrEnable = 1;
  reg [7:0] ipAddress;
  reg [31:0] ipWrData;
  UART_PACKET ipTxPacket;
  
  always #10 begin
    ipClk = ~ipClk;
  end

  initial begin
    #20 ipReset <= 0;
    #25 opTxWrEnable <= 1;
    ipTxPacket.Valid <= 1'b1;
    ipTxPacket.SoP <= 1'b1;
    ipTxPacket.EoP <= 0;
    ipTxPacket.Length <= 4;
    ipTxPacket.Data <= count;
    ipTxPacket.Source <= 8'h01;
    ipTxPacket.Destination <= 8'h01;
  end

  always @(posedge ipClk) begin
    if(count > 0 && !ipTxPacket.Valid) begin
      ipTxPacket.Valid <= 1'b1;
      if(count <= 1) begin
        ipTxPacket.EoP <= 1;
      end
    end else if(count === 0) begin
      $stop;
    end    
  end

  always @(posedge ipClk) begin
    if(ipTxPacket.Valid)begin
      ipTxPacket.Valid <= 0;
    end
    if (count == 0) begin
      $stop;
    end
  end

  always @(posedge ipTxPacket.Valid) begin
    count <= count - 1;
    ipTxPacket.Data <= count;
  end
  

    
   

  TxController DUT(
    .ipClk(ipClk),
    .ipReset(ipReset),
    .opAddress(ipAddress),
    .opWrData(ipWrData),
    .ipTxStream(ipTxPacket),
    .opTxWrEnable(opTxWrEnable)
  );

endmodule //TxController_TB