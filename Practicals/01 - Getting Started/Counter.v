module Counter (
    input ipClk,
    output [7:0] opLed 
);
    reg [30:0] counter;
  always @(posedge ipClk) begin
      counter++;
  end
  assign  opLed = counter[30:23];
endmodule //Counter