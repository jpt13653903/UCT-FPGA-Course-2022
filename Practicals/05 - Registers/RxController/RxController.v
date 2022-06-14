module RxController #(
  parameter DATA_LENGTH = 4
) (
  ipClk(ipClk),
    .ipReset(ipReset),
    .ipRdRegisters(ipRdRegisters),
    .opRdData(opRdData),
    .ipAddress(ipRxAddress),
    .opRxStream(opRxStream),
);

/*********************************************************************************************************************
 * FOR THE RECEIVE END WE ONLY RECEIVE THE ADDRESS AS DATA. WE WILL USE THE ADDRESS TO SELECT WHERE TO READ FROM AND *
 *                         SET THE DATA TO THE OUTPUT READ STREAM. WE NEED TO GATE ON VALID                          *
 *********************************************************************************************************************/
typedef enum { 
  IDLE,
  GET_ADDRESS,
  SEND_DATA,
 } state;

  
endmodule