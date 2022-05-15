import Structures::*;

`timescale 1ns/1ns
module UART_Packets_TB;
	reg ipClk = 0;
	reg ipRx;
	reg ipReset = 1;
	logic  opTxReady = 0;
	wire opTx;

	UART_PACKET ipTxStream;
	UART_PACKET opRxStream;



	always #10 begin
		ipClk <= ~ipClk;
	end

	initial begin
		ipTxStream.Source <= 100;
		ipTxStream.Destination <= 200;
		ipTxStream.Length <= 1;
		ipTxStream.SoP <= 1;
		ipTxStream.EoP <= 1;
		ipTxStream.Data <= 20;
		ipTxStream.Valid <= 1;
		ipReset <=0;
	end

	UART_Packets DUT(
		.ipClk(ipClk),
		.ipRx(ipRx),
		.ipReset(ipReset),
		.opTxReady(opTxReady),
		.opTx(opTx),
		.ipTxStream(ipTxStream),
		.opRxStream(opRxStream)
	);
endmodule //UART_Packets_TB