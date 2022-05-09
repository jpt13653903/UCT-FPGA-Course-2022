import Structures::*

module Registers (
	input		ipClk, 
	input		ipReset,	
	input 	RD_REGISTERS ipRdRegisters,
	output 	WR_REGISTERS opWrRegisters,
	input  	[7:0] ipAddress,
	input 	[31:0] ipWrData,
	input 	ipWrEnable,
	output reg [31:0] opRdData
);
	reg reset;
	always @(posedge ipClk) begin
		case(ipAddress) 
			8'h00: opRdData <= ipRdRegisters.ClockTicks;
			8'h00: opRdData <= ipRdRegisters.Buttons;
			8'h00: opRdData <= opWrRegisters.LEDs;
			default: opRdData <= 32'hX;
		endcase

		reset <= ipReset;

		if (reset) begin
			opWrRegisters.LEDs <= 0;	 	
		end else if (ipWrEnable) begin
			case (ipAddress)
				8'h02: opWrRegisters.LEDs <= ipWrData
			endcase
		end
	end

endmodule //Registers