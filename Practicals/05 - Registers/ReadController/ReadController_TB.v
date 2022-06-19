`timescale 1ns/1ns

import Structures::*;

module ReadController_TB;
	reg [31:0] ipReadData = 32'b0111_0110_0101_0100_0011_0010_0001_0000;
	reg opTxReady;
	reg ipClk = 0;
	reg ipReset = 1;
	reg [7:0] count = 0;
	UART_PACKET ipRxStream;
	UART_PACKET opTxStream;
	reg [7:0] opReadAddress;

	initial begin
		//Send Sync and destination for read
		#10 ipReset <= 0;
		ipRxStream.Destination <= 8'h00;
		ipRxStream.Valid <= 1;
		//initial data is address
		ipRxStream.Data <= 8'h11;
		opTxReady <= 1;
		opTxStream.Valid <= 1;
	end

	always #10 begin
		ipClk <= ~ipClk;
	end


	always @(posedge opTxStream.EoP) begin
		$stop;
	end

	ReadController DUT(
		.ipReadData(ipReadData),
		.opTxReady(opTxReady),
		.ipRxStream(ipRxStream),
		.opTxStream(opTxStream),
		.ipReset(ipReset),
		.ipClk(ipClk),
		.opReadAddress(opReadAddress)
	);
endmodule