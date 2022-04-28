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

module #(parameter Clock_Div = 10, parameter WIDTH = 8) UART(
  input           ipClk,
  input           ipReset,

  input      [WIDTH - 1:0]ipTxData,
  input           ipTxSend,
  output reg      opTxBusy,
  output reg      opTx,

  input           ipRx,
  output reg [WIDTH - 1:0]opRxData,
  output reg      opRxValid
);
	// Set local reset, count and clock enable
  reg reset;
  reg clockEnable;
	reg [3:0] count = 8;
	reg rx;
	reg [WIDTH -1:0] temp

	typedef enum {
		IDLE
		SENDING
		BUSY
	} State

	State state

	clockEnable = count == Clock_Div

		always @(posedge ipClk) begin
			count <= count - 1
			reset <= ipReset

			if (reset) begin
				opRxData <= 7'bX
				ipTxData <= 7'bX
			end else if(clockEnable) begin
				count <= WIDTH - 1;
			//------------------------------------------------------------------------------
			// TODO: Put the transmitter here
			//--------------- ---------------------------------------------------------------
			if (opTxBusy == 0) begin
				ipTxSend <= 1
				state <= SENDING
			end	else if(opTxBusy == 1) begin
				ipTxSend <= 0
				state <= BUSY
			end else {
				state <= IDLE
			}

			case(state)
				IDLE: begin
					temp <= ipTxData
				end
				SENDING: begin	
					{temp, opTx} <=  temp
				end
				BUSY: begin
					
				end
			endcase
		end
	end






	



// TODO: Put the receiver here

//------------------------------------------------------------------------------
	endmodule
//-----------------------------------------------------------------------------