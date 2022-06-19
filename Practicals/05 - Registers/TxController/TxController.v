import Structures::*;

module TxController #(DATA_LENGTH = 4) (
  input                 ipClk,
  input                 ipReset,
  input UART_PACKET     ipTxStream,

  output reg            opTxWrEnable,
  output reg [7:0]      opAddress,
  output reg [31:0]     opWrData
);
  typedef enum { 
    IDLE,
    GET_ADDRESS,
    GET_OPERATION, 
    GET_DATA
  } State;
  //local reset
  reg reset;
  State state;
  reg [3:0] dataLength;
 
  always @(posedge ipClk) begin
    reset <= ipReset;
    /******************************************************************************************************
    * PROCEDURE TO TRANSMIT INVOLVES COLLECTING 4 PACKETS AND STORING THEIR DATA IN THE WRITE REGISTERS. *
    * THE FIRST DATA ON SYNC WILL BE THE ADDRESS. EVERYTHING WILL BE DONE ON VALID, GATE ON OPTXWRENABLE *
    ******************************************************************************************************/
    if (reset) begin
      opWrData <= 32'bz;
      opAddress <= 8'bz;  
      state <= IDLE;
      opTxWrEnable <= 0;
    end else if (ipTxStream.Valid) begin
     case (state)
      IDLE: begin
        dataLength <= DATA_LENGTH;
        opTxWrEnable <=1;
        if(ipTxStream.Source == 8'h01 && ipTxStream.SoP == 1) begin
          opTxWrEnable <= 0;
          state <= GET_ADDRESS;
        end
      end
      GET_ADDRESS: begin
        opAddress <= ipTxStream.Data;
        state <= GET_DATA;
      end
      GET_DATA: begin
        if(dataLength > 0) begin
          dataLength <= dataLength -1;
          opWrData <= {opWrData, ipTxStream.Data};
          if(ipTxStream.EoP) begin
            state <= IDLE;
          end
        end else begin
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