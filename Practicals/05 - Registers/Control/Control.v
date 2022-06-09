module Control (
  input UART_PACKET ipTxPacket, 
	output UART_PACKET opRxPacket, 
	input ipReset,
	input ipClk
);

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
				if (localTxPacket.Valid && localTxPacket.Source == 0'x00 ) begin
					controlState <= CONTROL_READ_DATA;
				end else if(localTxPacket.Valid && localTxPacket.Source == 0'x00) begin
					controlState <= CONTROL_WRITE_DATA;
				end
			end
			CONTROL_READ_DATA: begin
				//use address to write to this location
				localRxData <= ipR
				opRxData.
				opRxData.Data <= localRxData

			end
			CONTROL_WRITE_DATA: begin
				//use address to read from this location
				localTxData <= ipTxPacket.Data
				if(ipTxPacket.Valid) begin	
					if(txLength > 1 ) begin
						localMemory <= { localTxData, localMemory[31:8]};
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