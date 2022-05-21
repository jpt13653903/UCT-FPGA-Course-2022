import Structures::*;
//------------------------------------------------------------------------------

module UART_Packets(
  input              ipClk,
  input              ipReset,

  input  UART_PACKET ipTxStream,
  output logic       opTxReady,
  output logic       opTx,

  input              ipRx,
  output UART_PACKET opRxStream
);
	//------------------------------------------------------------------------------
	// TODO: Instantiate the UART module here
	//------------------------------------------------------------------------------
	reg      	UART_TxSend;
	reg 		reset = 0;
	reg      	UART_TxBusy;
	reg      	UART_RxValid;
	reg  [7:0] 	UART_RX_DATA;
	reg  [7:0]	localTxData;
	reg  [7:0]	UART_TxData;

	typedef enum { 
		TX_IDLE, 
		TX_SEND_SYNC,
		TX_SEND_DESTINATION,
		TX_SEND_SOURCE,
		TX_SEND_LENGTH,
		TX_SEND_DATA, 
		TX_BUSY, 
		TX_FINISHED
	} TxState;
	
	typedef enum { 
		RX_IDLE, 
		RX_GET_DESTINATION, 
		RX_GET_SOURCE, 
		RX_GET_LENGTH, 
		RX_GET_DATA
	} RxState;	

	RxState rxState;
	TxState txState;
	reg [7:0] receiveDataLength  = 0;
	reg [7:0] transmitDataLength = 0;
	UART UART_INST(
		.ipClk    ( ipClk   		),
		.ipReset  ( reset 			),
		.ipTxData ( UART_TxData	    ),
		.ipTxSend ( UART_TxSend 	),
		.opTxBusy ( UART_TxBusy 	),
		.opTx     ( opTx  			),
		.ipRx     ( ipRx  			),
		.opRxData ( UART_RX_DATA 	),
		.opRxValid( UART_RxValid 	)
	);

	always @(posedge ipClk) begin
		//------------------------------------------------------------------------------	
		// TODO: Implement the Tx stream
		//------------------------------------------------------------------------------

		reset <= ipReset;
		
		if (reset) begin
			UART_TxBusy <= 0;
			UART_RxValid <= 0;
			opTxReady <= 1;
			rxState <= RX_IDLE;
			txState <= TX_IDLE;
		end

		case(txState)
			TX_IDLE: begin
				$display("Got here");
				$display("opTxReady %d", opTxReady);
				$display("Start off packet %d", ipTxStream.SoP);
				$display("ipTx valid %d", ipTxStream.Valid);
				localTxData <= ipTxStream.Data;
				if (ipTxStream.Valid && ipTxStream.SoP && opTxReady) begin
					$display("WE ARE NOT GETTING HERE");
					opTxReady <= 0;
					txState <= TX_SEND_SYNC;
				end else begin
					$display("OR HERE");
					if(!UART_TxBusy) begin
						opTxReady <= 1;
						UART_TxSend <= 0;
					end
				end
			end
			TX_SEND_SYNC: begin
				if(!UART_TxBusy && opTxReady && ipTxStream.Valid) begin
					UART_TxSend <= 1;
					UART_TxData <= 8'h55;
					opTxReady <= 0;
					txState <= TX_SEND_DESTINATION;
				end else begin
					if(!UART_TxBusy) begin
						opTxReady <= 1;
						UART_TxSend <= 0;
					end
				end
			end
			TX_SEND_DESTINATION: begin
				if(!UART_TxBusy && opTxReady && ipTxStream.Valid) begin
					UART_TxSend <= 1;
					UART_TxData <= ipTxStream.Destination;
					opTxReady <= 0;
					txState <= TX_SEND_SOURCE;
				end else begin
					if(!UART_TxBusy) begin	
						opTxReady <= 1;
						UART_TxSend <= 0;
					end
				end
			end
			TX_SEND_SOURCE: begin
				if(!UART_TxBusy && opTxReady && ipTxStream.Valid) begin
					UART_TxSend <= 1;
					UART_TxData <= ipTxStream.Source;
					opTxReady <= 0;
					txState <= TX_SEND_LENGTH;
				end else begin
					if(!UART_TxBusy) begin
						opTxReady <= 1;
						UART_TxSend <= 0;
					end
				end
			end
			TX_SEND_LENGTH: begin
				if(!UART_TxBusy && opTxReady && ipTxStream.Valid) begin
					UART_TxSend <= 1;
					UART_TxData <= ipTxStream.Length;
					transmitDataLength <= ipTxStream.Length;
					opTxReady <= 0;
					txState <= TX_SEND_DATA;
				end else begin
					if(!UART_TxBusy) begin
						opTxReady <= 1;
						UART_TxSend <= 0;
					end
				end
			end
			TX_SEND_DATA: begin
				 if(!UART_TxBusy && opTxReady && ipTxStream.Valid) begin

					if (transmitDataLength == 1) begin
						txState <= TX_IDLE;
					end else begin
						transmitDataLength <= transmitDataLength - 1;
					end
					UART_TxSend <= 1;
					UART_TxData <= ipTxStream.Data;
					opTxReady <= 0;
				end else begin
					if(!UART_TxBusy) begin
						opTxReady <= 1;
						UART_TxSend <= 0;
					end
				end
			end
		endcase
		

		//------------------------------------------------------------------------------
		// TODO: Implement the Rx stream
		//------------------------------------------------------------------------------
		if (UART_RxValid) begin

			case (rxState)
				RX_IDLE: begin
					if ( UART_RX_DATA == 8'h55  ) begin
						opRxStream.SoP <= 1;
						rxState <= RX_GET_DESTINATION;
					end
				end
				RX_GET_DESTINATION: begin
					opRxStream.Destination <= UART_RX_DATA;
					rxState <= RX_GET_SOURCE;
				end
				RX_GET_SOURCE: begin
					opRxStream.Source <= UART_RX_DATA;
					rxState <= RX_GET_LENGTH;
				end
				RX_GET_LENGTH: begin
					receiveDataLength <= UART_RX_DATA;
					opRxStream.Length <= UART_RX_DATA;
					rxState <= RX_GET_DATA;
				end
				RX_GET_DATA: begin
					opRxStream.Data <= UART_RX_DATA;
					opRxStream.Valid <= 1;
					if (receiveDataLength == 1) begin
						opRxStream.EoP <= 1;	
						rxState <= RX_IDLE;	
					end
					receiveDataLength <= receiveDataLength - 1;
				end
			endcase
		end else 
			if(opRxStream.Valid)begin
				opRxStream.SoP <= 0;
			opRxStream.Valid <= 0;
		end
	end
endmodule
