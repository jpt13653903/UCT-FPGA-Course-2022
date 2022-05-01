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

module UART(
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
	localparam WIDTH = 8;
	localparam CLOCK_DIV = 434;

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
	
	reg [3:0] txCounter = WIDTH + 1; // extra bits for start and stop bits
	reg [3:0] rxCounter = WIDTH + 1;
	reg clockEnable = 0;
	reg rxClockEnable = 0;
	reg reset;
	reg [WIDTH + 1:0] localTxData;
	reg [WIDTH + 1:0] localRxData;

	always @(posedge ipClk) begin
		localTxData <= ipTxData;
		reset <= ipReset;
		txCounter <= txCounter - 1;
		rxCounter <= rxCounter - 1;
		clockEnable = (txCounter == (CLOCK_DIV >> 1));
		rxClockEnable = (rxCounter == (CLOCK_DIV >> 1));


		if (reset) begin
			txCounter <= WIDTH + 1;
			clockEnable <= 0;
			txState <= IDLE;
		end else begin	

			//------------------------------------------------------------------------------
			// TODO: Put the transmitter here
			//------------------------------------------------------------------------------
			if(clockEnable == 1) begin
				case(txState)
					IDLE:begin
						localTxData <=  {1, ipTxData, 0};
						if(ipTxSend == 1)begin
							txCounter	 <= WIDTH + 1;
							txState <= SENDING;
						end
					end
					SENDING:begin
							{localTxData, opTx} <= localTxData;
							if(txCounter == 0)begin
								txState <= IDLE;
							end
					end
				endcase
			end

			//------------------------------------------------------------------------------
			// TODO: Put the receiver here
			//------------------------------------------------------------------------------
			
				case (rxState)
					RECEIVING: begin
						if(rxCounter ==  CLOCK_DIV + (CLOCK_DIV >> 1)) begin
							opRxData <= localRxData[8:1];
							rxState <= 	RECEIVER_IDLE;
							opRxValid <= 1;
						end
					end
					IDLE: begin
						if(rxClockEnable)begin
							localRxData <= {ipRx, localRxData};
							opRxValid <= 0;
							if(localRxData[0] == 0 && localRxData[9] == 1)begin
								rxCounter <= WIDTH + 1;
								rxState <= RECEIVING;
							end
						end
					end
				endcase
			end
	end

endmodule
