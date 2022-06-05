import Structures::*;
//------------------------------------------------------------------------------

module UART_Packets(
  input              ipClk,
  input              ipReset,

  input var  UART_PACKET ipTxStream,
  output logic       opTxReady,
  output logic       opTx,

  input              ipRx,
  output UART_PACKET opRxStream
);
	//------------------------------------------------------------------------------
	// TODO: Instantiate the UART module here
	//------------------------------------------------------------------------------
	reg					UART_TxSend;
	reg 				reset = 0;
	reg					UART_TxBusy;
	reg					UART_RxValid;
	reg  [7:0]	UART_RX_DATA;
	reg  [7:0]	UART_TxData;

	//Variables to store local values;
	reg [7:0] locaTxDestination;
	reg [7:0] localTxSource;
	reg [7:0] localTxLength;
	reg [7:0] localTxData;
	reg localTxValid;

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
		.ipClk    ( ipClk   				),
		.ipReset  ( reset 					),
		.ipTxData ( UART_TxData	    ),
		.ipTxSend ( UART_TxSend 		),
		.opTxBusy ( UART_TxBusy 		),
		.opTx     ( opTx  					),
		.ipRx     ( ipRx  					),
		.opRxData ( UART_RX_DATA 		),
		.opRxValid( UART_RxValid 		)
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
			UART_RxValid <= 0;
			UART_RX_DATA <= 8'bz;
			UART_TxData <= 8'bz;
			UART_TxSend <= 0;
		end
		
		case(txState)
			TX_IDLE: begin
				if(!UART_TxBusy && !UART_TxSend) begin
					opTxReady <= 1;
				end

				if (ipTxStream.Valid && ipTxStream.SoP && !UART_TxBusy && !UART_TxSend) begin
					locaTxDestination <= ipTxStream.Destination;
					localTxLength <= ipTxStream.Length;
					localTxSource <= ipTxStream.Source;
					localTxData <= ipTxStream.Data;
					localTxValid <= ipTxStream.Valid;

					UART_TxSend <= 1;
					opTxReady <= 0;
					txState <= TX_SEND_SYNC;
				end else begin
					if(UART_TxBusy) begin
						UART_TxSend <= 0;
					end
				end
			end

			TX_SEND_SYNC: begin
				UART_TxData <= 8'h55;
				if ( !UART_TxBusy && !UART_TxSend) begin
					UART_TxSend <= 1;
				end else if(UART_TxSend && UART_TxBusy) begin
					txState <= TX_SEND_DESTINATION;
					UART_TxSend <= 0;
				end 
			end

			TX_SEND_DESTINATION: begin
				UART_TxData <= locaTxDestination;
				if ( !UART_TxBusy && !UART_TxSend) begin
					UART_TxSend <= 1;
				end else if(UART_TxBusy && UART_TxSend)begin
					txState <= TX_SEND_SOURCE;
					UART_TxSend <= 0;
				end 
			end

			TX_SEND_SOURCE: begin
				UART_TxData <= localTxSource;
				if (!UART_TxBusy && !UART_TxSend) begin
					UART_TxSend <= 1;
				end else if(UART_TxBusy && UART_TxSend)begin
					txState <= TX_SEND_LENGTH;
					UART_TxSend <= 0;
				end 
			end

			TX_SEND_LENGTH: begin
				
				UART_TxData <= localTxLength;
				if (!UART_TxBusy && !UART_TxSend) begin
					UART_TxSend <= 1;
				end else if(UART_TxBusy && UART_TxSend)begin
					txState <= TX_SEND_DATA;
					UART_TxSend <= 0;
				end
			end

			TX_SEND_DATA: begin
				if(localTxValid) begin
					UART_TxData <= localTxData;
				end
				 
				if(!UART_TxBusy && !UART_TxSend) begin
					// check length
					opTxReady <= 0;
					localTxData <= ipTxStream.Data;
					localTxValid <= ipTxStream.Valid;
					$display("TRANSMIT DATA LENGTH, %d", transmitDataLength);
					UART_TxSend <= 1;
				end else if(UART_TxBusy && UART_TxSend) begin
					UART_TxSend <= 0;
					opTxReady <= 0;
					if (transmitDataLength == 1 || ipTxStream.EoP) begin
						txState <= TX_IDLE;
					end else begin
						localTxLength <= localTxLength - 1;
						opTxReady <=1;
					end
				end
			end
			default: txState <= TX_IDLE;
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
					//check length
					if (receiveDataLength == 1) begin
						opRxStream.EoP <= 1;	
						rxState <= RX_IDLE;	
					end
					receiveDataLength <= receiveDataLength - 1;
				end
			endcase
		end else if(opRxStream.Valid)begin
			opRxStream.SoP <= 0;
			opRxStream.Valid <= 0;
		end
	end
endmodule   
 
