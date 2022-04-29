`timescale 1ns/1ns

module Counter_TB;
	reg ipClk = 0;
	always #10000 begin
			ipClk <= ~ipClk;
	end

	reg ipReset = 1;

	initial begin
			@(posedge ipClk);
			@(posedge ipClk);
			@(posedge ipClk);
			ipReset <= 0;
	end

	wire [7:0] opLed;

	Counter DUT(
		.ipClk(ipClk),
		.opLed(opLed)
	);
endmodule //Counter_TB
