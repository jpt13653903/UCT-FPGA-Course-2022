/*==============================================================================
Copyright (C) John-Philip Taylor
jpt13653903@gmail.com

This file is part of the FPGA Masters Course

This file is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>
==============================================================================*/

/*------------------------------------------------------------------------------

A 2-to-1 stream merger.  If both inputs are fully utilised, the packets are
streamed out in alternating order.  The ready lines are buffered in order to
reduce fan-out to the sources.

If the stream contains metadata as well, it can be concatenated
with the data ports.
------------------------------------------------------------------------------*/

module StreamMerge #(
  parameter N
)(
  input             ipClk,
  input             ipReset,

  input             ipA_SoP,
  input             ipA_EoP,
  input      [N-1:0]ipA_Data,
  input             ipA_Valid,
  output reg        opA_Ready,

  input             ipB_SoP,
  input             ipB_EoP,
  input      [N-1:0]ipB_Data,
  input             ipB_Valid,
  output reg        opB_Ready,

  output reg        opSoP,
  output reg        opEoP,
  output reg [N-1:0]opData,
  output reg        opValid,
  input             ipReady
);
//------------------------------------------------------------------------------

reg Reset;
reg LastSent;

reg        SoP;
reg        EoP;
reg [N-1:0]Data;
reg        Valid;

// The ping-pong scheme is used so that there is only one buffer required
enum {Idle, SendA, SendB} State;
//------------------------------------------------------------------------------

always @(posedge ipClk) begin
  Reset <= ipReset;

  if(Reset) begin
    LastSent  <= 1'b0;
    opA_Ready <= 1'b0;
    opB_Ready <= 1'b0;

    opSoP     <= 1'b0;
    opEoP     <= 1'b0;
    opData    <=  'hX;
    opValid   <= 1'b0;

    SoP       <= 1'bX;
    EoP       <= 1'bX;
    Data      <=  'hX;
    Valid     <= 1'b0;

    State     <= Idle;
  //----------------------------------------------------------------------------

  end else begin
    case(State)
      Idle: begin
        if(opA_Ready) begin
          if(ipA_Valid && ipA_SoP) begin
            opSoP    <= ipA_SoP;
            opEoP    <= ipA_EoP;
            opData   <= ipA_Data;
            opValid  <= ipA_Valid;
            LastSent <= 1'b0;
            if(ipA_EoP) opA_Ready <= 1'b0;
            else        State     <= SendA;
          end else begin
            opSoP     <= 1'b0;
            opEoP     <= 1'b0;
            opData    <=  'hX;
            opValid   <= 1'b0;
            opA_Ready <= 1'b0;
            opB_Ready <= 1'b1;
          end

        end else if(opB_Ready) begin
          if(ipB_Valid && ipB_SoP) begin
            opSoP     <= ipB_SoP;
            opEoP     <= ipB_EoP;
            opData    <= ipB_Data;
            opValid   <= ipB_Valid;
            LastSent  <= 1'b1;
            if(ipB_EoP) opB_Ready <= 1'b0;
            else        State     <= SendB;
          end else begin
            opSoP     <= 1'b0;
            opEoP     <= 1'b0;
            opData    <=  'hX;
            opValid   <= 1'b0;
            opA_Ready <= 1'b1;
            opB_Ready <= 1'b0;
          end

        end else begin
          if(ipReady) begin
            opValid <= 1'b0;
            if(LastSent) begin // B was last sent
              opA_Ready <= 1'b1;
              opB_Ready <= 1'b0;
            end else begin
              opA_Ready <= 1'b0;
              opB_Ready <= 1'b1;
            end
          end
        end
      end
      //------------------------------------------------------------------------

      SendA: begin
        if(opA_Ready) begin
          if(ipReady) begin
            opSoP   <= ipA_SoP;
            opEoP   <= ipA_EoP;
            opData  <= ipA_Data;
            opValid <= ipA_Valid;
            if(ipA_EoP && ipA_Valid) begin
              opA_Ready <= 1'b0;
              State     <= Idle;
            end
          end else begin
            SoP       <= ipA_SoP;
            EoP       <= ipA_EoP;
            Data      <= ipA_Data;
            Valid     <= ipA_Valid;
            opA_Ready <= 1'b0;
          end
        end else begin
          if(ipReady) begin
            opSoP   <= SoP;
            opEoP   <= EoP;
            opData  <= Data;
            opValid <= Valid;
            if(EoP && Valid)
              State <= Idle;
            else
              opA_Ready <= 1'b1;
          end
        end
      end
      //------------------------------------------------------------------------

      SendB: begin
        if(opB_Ready) begin
          if(ipReady) begin
            opSoP   <= ipB_SoP;
            opEoP   <= ipB_EoP;
            opData  <= ipB_Data;
            opValid <= ipB_Valid;
            if(ipB_EoP && ipB_Valid) begin
              opB_Ready <= 1'b0;
              State     <= Idle;
            end
          end else begin
            SoP       <= ipB_SoP;
            EoP       <= ipB_EoP;
            Data      <= ipB_Data;
            Valid     <= ipB_Valid;
            opB_Ready <= 1'b0;
          end
        end else begin
          if(ipReady) begin
            opSoP   <= SoP;
            opEoP   <= EoP;
            opData  <= Data;
            opValid <= Valid;
            if(EoP && Valid)
              State <= Idle;
            else
              opB_Ready <= 1'b1;
          end
        end
      end
      //------------------------------------------------------------------------

      default:;
    endcase
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

