import Structures::*;
//------------------------------------------------------------------------------

module UART_Packets(
  input              ipClk,
  input              ipReset,

  input  UART_PACKET ipTxStream,
  output             opTxReady,
  output             opTx,

  input              ipRx,
  output UART_PACKET opRxStream
);
	//------------------------------------------------------------------------------
	// TODO: Instantiate the UART module here
	//------------------------------------------------------------------------------
	reg       UART_TxSend;
	reg reset = 0;
	wire      UART_TxBusy;
	wire      UART_RxValid;
	reg [7:0] UART_RX_DATA;
	reg [7:0]	localTxData;

	typedef enum { 
		TX_IDLE, 
		TX_SEND_SYNC,
		TX_SEND_DESTINATION,
		TX_SEND_SOURCE,
		TX_SEND_LENGTH,
		TX_SEND_DATA, 
		TX_BUSY, 
		TX_FINISHED,
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
	reg [8:0] transmitDataLength = 0;
	UART UART_INST(
		.ipClk    ( ipClk   ),
		.ipReset  ( reset ),
		.ipTxData ( ipTxStream.Data ),
		.ipTxSend ( UART_TxSend ),
		.opTxBusy ( UART_TxBusy ),
		.opTx     ( opTx  ),
		.ipRx     ( ipTx  ),
		.opRxData ( opRxStream.Data ),
		.opRxValid( UART_RxValid )
	)

	always @(posedge ipClk) begin
		//------------------------------------------------------------------------------	
		// TODO: Implement the Tx stream
		//------------------------------------------------------------------------------

		reset <= ipReset;
		
		if (reset) begin
			UART_TxBusy <= 1;
			UART_RxValid <= 0;
			opTxReady <= 0;
			rxState <= RX_IDLE;
			txState <= TX_IDLE;
		end

		
		case(txState)
			TX_IDLE: begin
				localRxData <= ipTxStream.Data;
				if (ipTxStream.Valid & ipTxStream.SoP & opTxReady) begin
					opTxReady <= 0;
					txState <= TX_SEND_SYNC;
				end else begin
					opTxReady <= 1;
				end
			end
			TX_SEND_SYNC: begin
				if(!UART_TxBusy) begin
					UART_TxSend <= 1;
					UART_TxData <= 8'h55;
					txState <= TX_SEND_DESTINATION;
				end
			end

			TX_SEND_DESTINATION: begin
				
			end
			TX_SEND_SOURCE: begin
				
			end
			TX_SEND_LENGTH: begin
				
			end
			TX_SEND_DATA: begin
				
			end
			TX_BUSY: begin
				
			end
			TX_FINISHED: begin
				
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
			end
			opRxStream.Valid <= 0;
		end
	end
endmodule
