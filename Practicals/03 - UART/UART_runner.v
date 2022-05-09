module top (
	output  opUART_Tx,
	input 	ipUART_Rx,
	input  	ipClk,
	input 	ipnReset,
	output reg [7:0] opLed
);
	reg  [7:0]UART_TxData;
	reg       UART_TxSend;
	wire      UART_TxBusy;

	wire [7:0]UART_RxData;
	wire      UART_RxValid;
 
	UART UART_Inst(
		.ipClk    ( ipClk   ),
		.ipReset  (~ipnReset),

		.ipTxData (  UART_TxData),
		.ipTxSend (  UART_TxSend),
		.opTxBusy (  UART_TxBusy),
		.opTx     (  opUART_Tx  ),
		.ipRx     (  ipUART_Rx   ),
		.opRxData (  UART_RxData ),
		.opRxValid(  UART_RxValid)
	);

	always @(posedge ipClk) begin
		opLed <= UART_RxData;
		if(~UART_TxSend && ~UART_TxBusy) begin
			case(UART_RxData) inside
				8'h0D    : UART_TxData <= 8'h0A; // Change enter to linefeed
				"0"      : UART_TxData <= 8'h0D; // Change 0 to carriage return
				["A":"Z"]: UART_TxData <= UART_RxData ^ 8'h20;
				["a":"z"]: UART_TxData <= UART_RxData ^ 8'h20;
				default  : UART_TxData <= UART_RxData;
			endcase
			UART_TxSend <= UART_RxValid;

		end else if(UART_TxSend && UART_TxBusy) begin
			UART_TxSend <= 0;
		end
	end
endmodule //top