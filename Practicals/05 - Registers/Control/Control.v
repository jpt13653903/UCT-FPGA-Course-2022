import Structures::*;

module Control #(parameter DATA_LENGTH = 4, parameter BIT_WIDTH = 8) (
  input 	UART_PACKET	ipTxPacket, 
	output 	UART_PACKET	opRxPacket, 
	input 							ipReset,
	input 							ipClk,
	input 							ipWrEnable,
	input		wire [31:0] ipReadMemory,
	output 	reg [31:0] opWriteMemory
);
	reg [4:0] dataLength;
	UART_PACKET localTxPacket;
	reg txLength;
	reg [7:0] operationAddress;
	reg [7:0] localTxData;
	reg [7:0] localRxData;
	reg [31:0] localMemory;
	reg localReset;

	typedef enum  { 
		CONTROL_IDLE,
		CONTROL_GET_ADDR,
		CONTROL_GET_OPERATION,
		CONTROL_GET_DATA,
		CONTROL_READ_DATA, 
		CONTROL_WRITE_DATA
	} ControlTxState;
	//create a packet here

	ControlTxState controlState;

	always @(posedge ipClk) begin	
		localReset <= ipReset;

		if(localReset) begin
			controlState <= CONTROL_IDLE;
		end

		case (controlState)
			CONTROL_IDLE: begin
				localTxPacket <= ipTxPacket;
				$display("I got here");
				$display("SoP, %d", localTxPacket.SoP);
				$display("Data %d", localTxPacket.Data );
				$display("Valid %d", localTxPacket.Valid);
				if(localTxPacket.Data == 8'h55 && localTxPacket.SoP && localTxPacket.Valid)begin
					$display("I AM FETCHING THE ADDRESS");
					controlState <= CONTROL_GET_ADDR;
					txLength <= localTxPacket.Length;
				end		
			end
			CONTROL_GET_ADDR: begin
				if (localTxPacket.Valid) begin
					
					operationAddress <= localTxPacket.Data;
					txLength <= txLength -1;
					controlState <= CONTROL_GET_OPERATION;
				end
			end
			CONTROL_GET_OPERATION: begin
				dataLength <= DATA_LENGTH;
				$display("I AM FETCHING THE OPERATION");
				if (localTxPacket.Valid && localTxPacket.Source == 8'h00 ) begin
					controlState <= CONTROL_READ_DATA;
				end else if(localTxPacket.Source == 8'h01) begin
					controlState <= CONTROL_WRITE_DATA;
				end
			end
			CONTROL_READ_DATA: begin
				$display("I GOT HERE");
				//use address to write to this location
				// during this state we want to send whatever data we have
				if(dataLength > 0 && opRxPacket.Valid) begin
					dataLength <= dataLength - 1;
					// opRxPacket.Data <= ipReadMemory[(BIT_WIDTH*dataLength) - 1:BIT_WIDTH  * (dataLength - 1)];
					
					if (dataLength == DATA_LENGTH) begin
						opRxPacket.SoP <= 1;
					end else if(dataLength == 1)  begin
						opRxPacket.EoP <= 1;
					end
					opRxPacket.Valid <= 1;
				end else begin
					opRxPacket.Valid <= 0;
				end

			end
			CONTROL_WRITE_DATA: begin
				$display("I am writing");
				//use address to read from this location
				//during this state we want to store whatever data is incoming
				localTxData <= ipTxPacket.Data;
				if(ipTxPacket.Valid && ipWrEnable) begin	// only enable write on valid and enable
					// shift the bits in 
					opWriteMemory <= { localTxData, opWriteMemory[31:8]};
					if(txLength !=0) begin
						txLength <= txLength -1;
					end else begin
						controlState <= CONTROL_IDLE;
					end
				end
			end
			default: begin
				
			end
		endcase
	end
endmodule //Control