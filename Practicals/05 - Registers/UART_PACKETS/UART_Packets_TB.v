import Structures::*;

`timescale 1ns/1ns
module UART_Packets_TB;
	reg ipClk = 0;
	reg ipRx;
	reg ipReset = 1;
	wire opTxReady;
	wire opTx;

	UART_PACKET ipTxStream;
	UART_PACKET opRxStream;

	always #10 begin
		ipClk <= ~ipClk;
	end

	initial begin
		ipReset <=0;
		


	end

	UART DUT(
		.ipClk(ipClk)
		.ipRx(ipRx)
		.ipReset(ipReset)
		.ipTxStream(ipTxStream)
		.opTxReady(opTxReady)
		.opTx(opTx)
		.ipRx(ipRx)
		.opRxStream(opRxStream)
	)
endmodule //UART_Packets_TB