import Structures::*;

`timescale 1ns/1ns
module UART_Packets_TB;
	reg ipClk = 0;
	reg ipRx;
	reg ipReset = 1;
	reg  opTxReady = 0;
	wire opTx;

	UART_PACKET ipTxStream;
	UART_PACKET opRxStream;

	initial begin
		@(posedge ipClk);
		ipReset <= 0;
	end

	always #10 begin
		ipClk <= ~ipClk;
	end

	integer i = 10;
	initial begin
		ipTxStream.Source <= 100;
		ipTxStream.Destination <= 200;
		ipTxStream.Length <= 4;
		ipTxStream.SoP <= 1;
		ipTxStream.EoP <= 0;
		ipTxStream.Data <= i;
		ipTxStream.Valid <= 0;
	end

	always @(posedge opTxReady) begin
			ipTxStream.Valid <= 1;
			$display("I ===== %d", i);
			if(i==0) begin
				$stop;	
			end 
			ipTxStream.Data <= i;
	end

	always @(negedge ipTxStream.Valid) begin
			if(!opTxReady) begin
				i<= i-1;
				ipTxStream.SoP <= 0;
			end

			if (opTxReady) begin
				ipTxStream.SoP <= 0;
			end

			if(i == 3 ) begin
				ipTxStream.EoP = 1;
			end
	end

	always @(negedge opTxReady) begin
		ipTxStream.Valid <= 0;
	end

	UART_Packets DUT(
		.ipClk(ipClk),
		.ipRx(opTx),
		.ipReset(ipReset),
		.opTxReady(opTxReady),
		.opTx(opTx),
		.ipTxStream(ipTxStream),
		.opRxStream(opRxStream)
	);

  
endmodule //UART_Packets_TB
