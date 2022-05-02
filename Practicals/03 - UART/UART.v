/*------------------------------------------------------------------------------

Implements a 115 200 Bd UART.  ipClk is assumed to be 50 MHz

To send data:

- Set up ipTxData
- Wait for opTxBusy to be low
- Make ipTxSend high
- Wait for opTxBusy to go high
- Make ipTxSend low

To receive data:

- Wait for opRxValid to be high
- opRxData is valid during the same clock cycle
------------------------------------------------------------------------------*/

module UART #(parameter WIDTH =8, parameter CLOCK_DIV = 434) (
  input           ipClk,
  input           ipReset,

  input      [7:0] ipTxData,
  input           ipTxSend,
  output reg      opTxBusy,
  output reg      opTx,

  input           ipRx,
  output reg [7:0] opRxData,
  output reg      opRxValid
);
	typedef enum {
		SENDING,
		IDLE,
		BUSY
	} TxState;

	typedef enum {
		RECEIVING,
		RECEIVER_IDLE
	} RxState;

	TxState txState;
	RxState rxState;
	// localise the data to send and reset
	
	reg [8:0] txCounter = CLOCK_DIV - 1; // extra bits for start and stop bits
	reg [8:0] rxCounter =  CLOCK_DIV - 1;
	reg clockEnable = 0;
	reg rxClockEnable = 0;
	reg reset;
	reg [WIDTH + 1:0] localTxData;
	reg [WIDTH + 1:0] localRxData;

	
	always @(posedge ipClk) begin
		localTxData <= ipTxData;
		
		rxCounter <= rxCounter - 1;
		reset <= ipReset;

		if (reset) begin
			$display("I AM RESETTING");
			txCounter <= CLOCK_DIV - 1;
			rxCounter <= CLOCK_DIV - 1;
			clockEnable <= 0;
			rxState <= RECEIVER_IDLE;
			txState <= IDLE;
		end else begin	
			if(txCounter == 0)begin
				txCounter <= CLOCK_DIV - 1;
			end else begin
				txCounter <= txCounter - 1;
			end
			clockEnable = txCounter == 0 ? 1 : 0;
			//------------------------------------------------------------------------------
			// TODO: Put the transmitter here
			//------------------------------------------------------------------------------
			if(clockEnable == 1) begin
				case(txState)
					IDLE:begin
						$display("I AM IDLE");
						localTxData <=  {1'b1, ipTxData, 1'b0};
						if(ipTxSend == 1)begin
							txState <= SENDING;
							opTxBusy <= 1;
						end
					end
					SENDING:begin
							$display("I AM SENDING %b", localTxData);
							{localTxData, opTx} <= localTxData;
							if(txCounter == 0)begin
								txState <= IDLE;
								opTxBusy <= 0;
							end
					end
				endcase
			end

			//------------------------------------------------------------------------------
			// TODO: Put the receiver here
			//------------------------------------------------------------------------------		
				case (rxState)
					RECEIVING: begin
						if(rxCounter ==  0) begin
							opRxData <= localRxData[8:1];
							rxState <= 	RECEIVER_IDLE;
							rxCounter <= CLOCK_DIV - 1;
							opRxValid <= 1;
						end
					end
					RECEIVER_IDLE: begin
						if(rxClockEnable)begin
							localRxData <= {ipRx, localRxData};
							opRxValid <= 0;
							if(localRxData[0] == 0 && localRxData[9] == 1)begin
								// synchronize
								rxCounter <= CLOCK_DIV + (CLOCK_DIV >> 1);
								rxState <= RECEIVING;
							end
						end
					end
				endcase
			end
	end

endmodule
