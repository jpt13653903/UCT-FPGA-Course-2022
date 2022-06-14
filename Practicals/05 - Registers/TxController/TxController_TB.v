`timescale 1ns/1ns

import Structures::*;

module TxController_TB;
  reg ipClk = 0;
  reg ipReset = 1'b1;
  reg opTxReady = 1'b1;
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
     opTxReady = 1'b1;
    ipTxPacket.SoP <= 1'b1;
    ipTxPacket.EoP <= 0;
    ipTxPacket.Length <= 4;
    ipTxPacket.Data <= count;
    ipTxPacket.Source <= 8'h01;
    ipTxPacket.Destination <= 8'h01;
  end

  always @(posedge ipClk) begin
    ipTxPacket.Data <= count;
    if (count>0) begin
    
      if(count > 0 && !ipTxPacket.Valid && !opTxReady) begin
        $display("VALID? %d", ipTxPacket.Valid);
        ipTxPacket.Valid <= 1'b1;
        opTxReady <= 1'b1;
      end else if(count === 0) begin
        $stop;
      end    
    end
  end

  always @(negedge opTxWrEnable) begin
    $display("WHY ARE WE DOING THIS");
    ipTxPacket.Valid <= 0;
    opTxReady <= 0;
    if (count == 0) begin
      $stop;
    end
  end

  always @(posedge opTxWrEnable) begin
    count <= count - 1;
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