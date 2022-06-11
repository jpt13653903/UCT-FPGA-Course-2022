module Control #(param DATA_LENGTH = 4, param BIT_WIDTH = 8) (
  input UART_PACKET ipTxPacket, 
	output UART_PACKET opRxPacket, 
	input ipReset,
	input ipClk,
	input ipWrEnable,
	input wire [31:0] ipReadMemory,
	output wire [31:0] opWriteMemory
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

	ControlTxState controlState

	always @(posedge ipClk) begin	
		localReset <= ipReset;

		if(localReset)begin
			controlState <= CONTROL_IDLE;
			localSync <= 8'bz;
			localSource <= 8'bz;
		end

		case (controlState)
			CONTROL_IDLE: begin
				localTxPacket <= ipTxPacket;
				if(localTxPacket.Data == 8'h55 && localTxData.SoP && localTxPacket.Valid)begin
					controlState <= CONTROL_GET_DATA;
					txLength <= localTxPacket.Length;
				end		
			end
			CONTROL_GET_ADDR: begin
				if (localTxPacket.Valid) begin
					operationAddress <= localTxPacket.Data;
					txLength <= txLength -1;
					controlState <= CONTROL_GET_DATA;
				end
			end
			CONTROL_GET_OPERATION: begin
				dataLength <= DATA_LENGTH;
				if (localTxPacket.Valid && localTxPacket.Source == 0'x00 ) begin
					controlState <= CONTROL_READ_DATA;
				end else if(localTxPacket.Source == 0'x01) begin
					controlState <= CONTROL_WRITE_DATA;
				end
			end
			CONTROL_READ_DATA: begin
				//use address to write to this location
				// during this state we want to send whatever data we have
				if(dataLength > 0 && opRxPacket.Valid) begin
					dataLength <= dataLength - 1;
					opRxPacket.Data <= ipReadMemory[(BIT_WIDTH*dataLength) - 1:BIT_WIDTH  * (dataLength - 1)]
					
					if (dataLength == DATA_LENGTH) begin
						opRxPacket.SoP <= 1;
					end else if(dataLength == 1)  begin
						opRxPacket.Eop <= 1;
					end
					opRxPacket.Valid <= 1;
				end else begin
					opRxPacket.Valid <= 0;
				end

			end
			CONTROL_WRITE_DATA: begin
				//use address to read from this location
				//during this state we want to store whatever data is incoming
				localTxData <= ipTxPacket.Data
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