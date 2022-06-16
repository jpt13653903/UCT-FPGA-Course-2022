module ReadController #(
  parameter DATA_LENGTH = 4
) (
    
    input [31:0] ipReadData,
    input reg opTxReady,
    input UART_PACKET ipRxStream,
    output UART_PACKET opTxStream,
    output reg opReadAddress
);

  reg reset;
  reg dataLength;

  /*********************************************************************************************************************
  * FOR THE READING END WE ONLY RECEIVE THE ADDRESS AS DATA. WE WILL USE THE ADDRESS TO SELECT WHERE TO READ FROM AND *
  *                         SET THE DATA TO THE OUTPUT READ STREAM. WE NEED TO GATE ON VALID                          *
  *********************************************************************************************************************/
  typedef enum { 
    IDLE,
    GET_ADDRESS,
    SET_DATA,
  } State;

  State state;
  always @(posedge ipClk) begin
    if(reset) begin
      dataLength <= DATA_LENGTH;
      state <= IDLE;
    end else begin
      if (ipRxStream.Valid) begin
         case (state)
          IDLE: begin
            dataLength <= DATA_LENGTH;
            opTxStream.Valid <= 0;
            opTxStream.Source <=  8'hz; // can be anything, not sure if it matters
            opTxStream.Destination <= 8'hz; // we have to write in the receiver
            opTxStream.Length <= DATA_LENGTH;
            if (ipRxStream.Destination == 8'h00 && ipRxStream.Valid) begin
              state <= GET_ADDRESS;
            end
          end
          GET_ADDRESS: begin
            opAddress <= ipRxStream.Data;
          end
          SET_DATA: begin
            if (opTxReady) begin
              // we have to read 4 bytes here and send them back
              opTxStream.Valid <= 1;
              opTxStream.Source <= ipRxStream.Source; // can be anything, not sure if it matters
              opTxStream.Destination <= 8'h01; // we have to write in the receiver
              opTxStream.Length <= DATA_LENGTH;

              dataLength <= dataLength - 1;
              case(dataLength)
                4:begin
                  opTxStream.SoP <= 1;
                  opTxStream.Data <= ipReadData[31:24];
                end
                3: begin
                  opTxStream.Sop <= 0;
                  opTxStream.Data <= ipReadData[23:16];
                end
                2: begin
                  opTxStream.Data <= ipReadData[15:8];
                end
                1: begin
                  opTxStream.Data <= ipReadData[7:0];
                  opTxStream.EoP <= 1;
                  state <= IDLE;
                end
                default: begin
                  state <= IDLE;
                end 
              endcase

            end
          end
          default: begin
            state <= IDLE;
          end
        endcase
      end


     
    end
  end


  
endmodule