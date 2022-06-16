module RxController #(
  parameter DATA_LENGTH = 4
) (
    .ipClk(ipClk),
    .ipReset(ipReset),
    .ipRdRegisters(ipRdRegisters),
    .opRdData(opRdData),
    .ipAddress(ipRxAddress),
    .opRxStream(opRxStream),
);

  reg reset;
  reg dataLength;

  /*********************************************************************************************************************
  * FOR THE RECEIVE END WE ONLY RECEIVE THE ADDRESS AS DATA. WE WILL USE THE ADDRESS TO SELECT WHERE TO READ FROM AND *
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
      dataLength <= 4;
      state <= IDLE;
    end else begin
      if (ipRxStream.Valid) begin
         case (state)
          IDLE: begin
            //Check for the sync bit


          end
          GET_ADDRESS: begin
            
          end
          SET_DATA: begin
            
          end
          default: begin
            state <= IDLE;
          end
        endcase
      end


     
    end
  end


  
endmodule