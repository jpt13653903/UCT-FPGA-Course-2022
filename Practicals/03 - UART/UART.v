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

module (
	parameter WIDTH = 8,
	parameter CLOCK_DIV = 434
) UART(
  input           ipClk,
  input           ipReset,

  input      [WIDTH - 1:0] ipTxData,
  input           ipTxSend,
  output reg      opTxBusy,
  output reg      opTx,

  input           ipRx,
  output reg [WIDTH - 1:0]opRxData,
  output reg      opRxValid
);

	typedef enum {
		SENDING,
		IDLE,
		BUSY
	} TxState;

	typedef enum {
		RECEIVING,
		IDLE
	} RxState

	TxState txState;
	RxState rxState;
	// localise the data to send and reset
	
	reg [2:0] txCounter = WIDTH - 1;
	reg [2:0] rxCounter = WIDTH -1;
	reg clockEnable = 0;
	reg [WIDTH - 1:0] localTxData;

	//------------------------------------------------------------------------------
	// TODO: Put the transmitter here
	//------------------------------------------------------------------------------
	always @(posedge ipClk) begin
		reg [WIDTH - 1:0] localTxData <= ipTxData;
		reg reset <= ipReset;
		txCounter <= txCounter - 1;
		clockEnable = txCounter == CLOCK_DIV/2;

		if (reset) begin
			txCounter <= WIDTH - 1;
			clockEnable <= 0;
			txState <= IDLE;
		end else if(clockEnable == 1) begin
			case(txState)
				IDLE:begin
					temp <= ipTxData;
					if(ipTxSend == 1)begin
						txCounter	 <= WIDTH - 1;
						txState <= SENDING;
					end
				end
				SENDING:begin
						{localTxData, opTx} <=  localTxData;
						if(txCounter == 0){
							txState <= IDLE;
						}
				end
			endcase
		end


		case (rXState)
			RECEIVING: begin
				
			end
			IDLE: begin
				
				if(opRxValid)begin
					
				end
			end
		endcase
	end
	//------------------------------------------------------------------------------
	// TODO: Put the receiver here
	//------------------------------------------------------------------------------
endmodule
