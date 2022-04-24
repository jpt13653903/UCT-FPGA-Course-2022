# Universal Asynchronous Receiver-Transmitter

- [The Module Black Box](#the-module-black-box)
- [Testbench](#testbench)
- [Running on Hardware](#running-on-hardware)

For this practical, implement a
[UART](https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter)
running at a hard-coded 115&nbsp;200 Bd.

## The Module Black Box

Create a new `UART` module, based on the black box below.

```SystemVerilog
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

module UART(
  input           ipClk,
  input           ipReset,

  input      [7:0]ipTxData,
  input           ipTxSend,
  output reg      opTxBusy,
  output reg      opTx,

  input           ipRx,
  output reg [7:0]opRxData,
  output reg      opRxValid
);
//------------------------------------------------------------------------------

// TODO: Put the transmitter here

//------------------------------------------------------------------------------

// TODO: Put the receiver here

//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------
```

## Testbench

You can use the following automated test bench to test your UART.  If the UART
is not doing what it is supposed to, the simulation will print an error message
on the `Transcript` at the bottom of the screen.

Do not worry about the details of the test bench.  This will be explained in a 
future lecture.

```SystemVerilog
`timescale 1ns/1ns // unit/precision
module UART_TB;
//------------------------------------------------------------------------------

reg ipClk = 0;
always #10 ipClk <= ~ipClk;
//------------------------------------------------------------------------------

reg ipReset = 1;
initial begin
  @(posedge ipClk);
  @(posedge ipClk);
  @(posedge ipClk);
  ipReset <= 0;
end
//------------------------------------------------------------------------------

reg  [7:0]ipTxData;
reg       ipTxSend;
wire      opTxBusy;
wire      opTx;

integer TxBit;

initial begin
  ipTxSend = 0;

  @(negedge ipReset);
  @(posedge ipClk);

  while(1) begin
    ipTxData = $urandom_range(0, 255);
    if(opTxBusy) @(negedge opTxBusy);

    assert(opTx == 1) else
      $error("Tx should idle high");

    @(posedge ipClk);
    ipTxSend = 1;

    @(posedge opTxBusy);
    @(posedge ipClk);
    ipTxSend = 0;

    #4340;
    assert(opTx == 0) else
      $error("Expecting start bit");

    for(TxBit = 0; TxBit < 8; TxBit++) begin
      #8681;
      assert(opTx == ipTxData[TxBit]) else
        $error("Incorrect data bit");
    end

    #8681;
    assert(opTx == 1) else
      $error("Expecting stop bit");
  end
end
//------------------------------------------------------------------------------

reg       ipRx;
wire [7:0]opRxData;
wire      opRxValid;

reg  [7:0]RxData;
integer   RxBit;

initial begin
  ipRx = 1;

  @(negedge ipReset);
  @(posedge ipClk);

  while(1) begin
    #($urandom_range(5000, 50000));

    RxData = $urandom_range(0, 255);

    ipRx = 0;
    #8681;
    for(RxBit = 0; RxBit < 8; RxBit++) begin
      ipRx = RxData[RxBit];
      #8681;
    end
    ipRx = 1;

    @(posedge opRxValid);
    #1;
    assert(opRxData == RxData) else
      $error("Rx Data Error");
  end
end
//------------------------------------------------------------------------------

UART DUT(
  .ipClk    (ipClk    ),
  .ipReset  (ipReset  ),
                      
  .ipTxData (ipTxData ),
  .ipTxSend (ipTxSend ),
  .opTxBusy (opTxBusy ),
  .opTx     (opTx     ),
                      
  .ipRx     (ipRx     ),
  .opRxData (opRxData ),
  .opRxValid(opRxValid)
);
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------
```

## Running on Hardware

When your UART is working in simulation, incorporate it into the counting LED
project.  Remember to correctly map the pins.

Also note that Lattice Diamond sometimes changes the top level entity when 
adding more files.  Make sure that the `Counter` module is still the top level 
entity after adding the UART.

Another thing to note is the programming file.  Lattice Diamond uses an 
absolute path for the JEDEC file, so make sure you're programming
the correct one.

A good test is to echo back the character with bit 6 inverted.  In other 
words, 0x61 should echo 0x41, and vice versa.  This changes the case of the 
letter.

You can do this with something like the following in the top-level module.

```SystemVerilog
reg  [7:0]UART_TxData;
reg       UART_TxSend;
wire      UART_TxBusy;

wire [7:0]UART_RxData;
wire      UART_RxValid;

UART UART_Inst(
  .ipClk    ( ipClk   ),
  .ipReset  (~ipnReset),

  .ipTxData (  UART_TxData),
  .ipTxSend (  UART_TxSend),
  .opTxBusy (  UART_TxBusy),
  .opTx     (opUART_Tx    ),

  .ipRx     (ipUART_Rx     ),
  .opRxData (  UART_RxData ),
  .opRxValid(  UART_RxValid)
);

always @(posedge ipClk) begin
  if(~UART_TxSend && ~UART_TxBusy) begin
    case(UART_RxData) inside
      8'h0D    : UART_TxData <= 8'h0A; // Change enter to linefeed
      "0"      : UART_TxData <= 8'h0D; // Change 0 to carriage return
      ["A":"Z"]: UART_TxData <= UART_RxData ^ 8'h20;
      ["a":"z"]: UART_TxData <= UART_RxData ^ 8'h20;
      default  : UART_TxData <= UART_RxData;
    endcase
    UART_TxSend <= UART_RxValid;

  end else if(UART_TxSend && UART_TxBusy) begin
    UART_TxSend <= 0;
  end
end
```

When you're done, test that it's working by means of PuTTY
(or similar serial terminal)

