import Structures::*;

module TxController #(DATA_LENGTH = 4) (
  input                 ipClk,
  input                 ipReset,
  input                 ipTxReady,
  input UART_PACKET     ipTxStream,

  output reg            opTxWrEnable
  output WR_REGISTERS   opWrRegisters,
  output reg [7:0]      opAddress,
  output reg [31:0]     opWrData,
);
  typedef enum type { 
    IDLE,
    GET_ADDRESS,
    GET_OPERATION, 
    GET_DATA,
  } State;
  //local reset
  reg reset;
  State state;
  reg [3:0] dataLength;
 
  always @(posedge ipClk) begin
    reset <= ipReset;
    if (reset) begin
      opWrData <= 32'bz;
      opAddress <= 8'bz;  
      State <= IDLE;
      opTxWrEnable <= 0;
    end

    /******************************************************************************************************
    * PROCEDURE TO TRANSMIT INVOLVES COLLECTING 4 PACKETS AND STORING THEIR DATA IN THE WRITE REGISTERS. *
    * THE FIRST DATA ON SYNC WILL BE THE ADDRESS. EVERYTHING WILL BE DONE ON VALID AND READY.            *
    ******************************************************************************************************/

    if (ipTxStream.Valid && ipTxReady) begin
     case (state)
      IDLE: begin
        dataLength <= DATA_LENGTH;
        opTxWrEnable <= 0;
        if(ipTxStream.Source == 8'h01) begin
          state <= GET_ADDRESS;
        end
      end
      GET_ADDRESS: begin
        opAddress <= ipTxStream.Data;
        state <= 
      end
      GET_DATA: begin
        if(dataLength > 0) begin
          dataLength <= dataLength -1;
          opWrData <= {opWrData, ipTxStream.Data}
        end else begin
          opTxWrEnable <= 1;
          state <= IDLE;
        end
      end
      default: begin
        state <= IDLE;
      end 
     endcase
    end
  end
endmodule //TransmitController