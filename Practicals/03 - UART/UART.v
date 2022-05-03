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
	reg[4:0] txBitCounter = WIDTH + 1;
	reg clockEnable = 0;
	reg rxClockEnable = 0;
	reg reset;
	reg [WIDTH + 1:0] localTxData;
	reg [WIDTH + 1:0] localRxData;

	
	always @(posedge ipClk) begin
		
		reset <= ipReset;

		if (reset) begin
			txCounter <= CLOCK_DIV - 1;
			rxCounter <= CLOCK_DIV - 1;
			clockEnable <= 0;
			rxState <= RECEIVER_IDLE;
			txState <= IDLE;
			opTx <=1;
			localRxData <= 10'h3FF;
		end else begin	
			if(txCounter == 0)begin
				txCounter <= CLOCK_DIV - 1;
			end else begin
				txCounter <= txCounter - 1;
			end
			clockEnable = txCounter == 0;
			//------------------------------------------------------------------------------
			// TODO: Put the transmitter here
			//------------------------------------------------------------------------------
			if(clockEnable == 1) begin
				case(txState)
					IDLE:begin
						
						localTxData <=  {1'b1, ipTxData, 1'b0};
						if(ipTxSend == 1)begin
							txState <= SENDING;
							txBitCounter <= WIDTH + 1;
							opTxBusy <= 1;
						end
					end
					SENDING:begin
							{localTxData, opTx} <= localTxData;
							txBitCounter <= txBitCounter - 1;
							if(txBitCounter == 0)begin
							
								txState <= IDLE;
								opTxBusy <= 0;
							end
					end
				endcase
			end

			//------------------------------------------------------------------------------
			// TODO: Put the receiver here
			//------------------------------------------------------------------------------		
			if (rxCounter == 0) begin
					opRxValid <= 0;
					rxCounter <= CLOCK_DIV - 1;
					localRxData <= {ipRx, localRxData[9:1]};
			end else begin
				if (localRxData[0] == 0 && localRxData[9] == 1) begin
					opRxValid <= 1;
					opRxData <= localRxData[8:1];
					localRxData <= 10'h3FF;
				end else begin
					opRxValid <= 0;
				end
				rxCounter <= rxCounter - 1;
			end 
		end
	end

endmodule
