// Typical run-time = 10 us
//------------------------------------------------------------------------------

module StreamMerge_TB;
//------------------------------------------------------------------------------

typedef struct{
  logic      SoP;
  logic      EoP;
  logic [7:0]Data;
  logic      Valid;
  logic      Ready;
} Stream;
//------------------------------------------------------------------------------

reg ipClk = 1;
always #10 ipClk = ~ipClk;
//------------------------------------------------------------------------------

reg ipReset = 1;
initial begin
  @(posedge ipClk);
  @(posedge ipClk);
  @(posedge ipClk);
  ipReset = 0;
end
//------------------------------------------------------------------------------

Stream A;
Stream B;
Stream C;
Stream D;

always begin: Stream_A
  integer n;

  A.SoP   <= 1'b0;
  A.EoP   <= 1'b0;
  A.Data  <=    0;
  A.Valid <= 1'b0;

  @(negedge ipReset);
  @(posedge ipClk);
  @(posedge ipClk);

  forever begin
    for(n = 0; n < 16; n++) begin
      A.SoP   <= (n ==  0);
      A.EoP   <= (n == 15);
      A.Data  <= 8'hA0 + n;
      A.Valid <= 1'b1;
      @(posedge ipClk);
      while(!A.Ready) @(posedge ipClk);
    end
  end
end
//------------------------------------------------------------------------------

always begin: Stream_B
  integer n;

  B.SoP   <= 1'b0;
  B.EoP   <= 1'b0;
  B.Data  <=    0;
  B.Valid <= 1'b0;

  @(negedge ipReset);
  @(posedge ipClk);
  @(posedge ipClk);

  forever begin
    for(n = 0; n < 16; n++) begin
      B.SoP   <= (n ==  0);
      B.EoP   <= (n == 15);
      B.Data  <= 8'hB0 + n;
      B.Valid <= 1'b1;
      @(posedge ipClk);
      while(!B.Ready) @(posedge ipClk);
    end
  end
end
//------------------------------------------------------------------------------

always begin: Stream_C
  integer n;

  C.SoP   <= 1'b0;
  C.EoP   <= 1'b0;
  C.Data  <=    0;
  C.Valid <= 1'b0;

  @(negedge ipReset);
  @(posedge ipClk);
  @(posedge ipClk);

  forever begin
    for(n = 0; n < 16; n++) begin
      C.SoP   <= (n ==  0);
      C.EoP   <= (n == 15);
      C.Data  <= 8'hC0 + n;
      C.Valid <= 1'b1;
      @(posedge ipClk);
      while(!C.Ready) @(posedge ipClk);
    end
  end
end
//------------------------------------------------------------------------------

always begin: Stream_D
  integer l, n;

  D.SoP   <= 1'b0;
  D.EoP   <= 1'b0;
  D.Data  <=    0;
  D.Valid <= 1'b0;

  @(negedge ipReset);
  @(posedge ipClk);
  @(posedge ipClk);

  forever begin
    for(l = 0; l < 16; l++) begin // Test different lengths
      for(n = 0; n <= l; n++) begin
        D.SoP   <= (n == 0);
        D.EoP   <= (n == l);
        D.Data  <= 8'hD0 + n;
        D.Valid <= 1'b1;
        @(posedge ipClk);
        while(!D.Ready) @(posedge ipClk);
      end
    end
  end
end
//------------------------------------------------------------------------------

Stream AB;
Stream CD;
Stream ABCD;

StreamMerge #(8) DUT_AB(
  .ipClk    (ipClk   ),
  .ipReset  (ipReset ),

  .ipA_SoP  (A.SoP   ),
  .ipA_EoP  (A.EoP   ),
  .ipA_Data (A.Data  ),
  .ipA_Valid(A.Valid ),
  .opA_Ready(A.Ready ),

  .ipB_SoP  (B.SoP   ),
  .ipB_EoP  (B.EoP   ),
  .ipB_Data (B.Data  ),
  .ipB_Valid(B.Valid ),
  .opB_Ready(B.Ready ),

  .opSoP    (AB.SoP  ),
  .opEoP    (AB.EoP  ),
  .opData   (AB.Data ),
  .opValid  (AB.Valid),
  .ipReady  (AB.Ready)
);

StreamMerge #(8) DUT_CD(
  .ipClk    (ipClk   ),
  .ipReset  (ipReset ),

  .ipA_SoP  (C.SoP   ),
  .ipA_EoP  (C.EoP   ),
  .ipA_Data (C.Data  ),
  .ipA_Valid(C.Valid ),
  .opA_Ready(C.Ready ),

  .ipB_SoP  (D.SoP   ),
  .ipB_EoP  (D.EoP   ),
  .ipB_Data (D.Data  ),
  .ipB_Valid(D.Valid ),
  .opB_Ready(D.Ready ),

  .opSoP    (CD.SoP  ),
  .opEoP    (CD.EoP  ),
  .opData   (CD.Data ),
  .opValid  (CD.Valid),
  .ipReady  (CD.Ready)
);

StreamMerge #(8) DUT_ABCD(
  .ipClk    (ipClk     ),
  .ipReset  (ipReset   ),

  .ipA_SoP  (AB.SoP    ),
  .ipA_EoP  (AB.EoP    ),
  .ipA_Data (AB.Data   ),
  .ipA_Valid(AB.Valid  ),
  .opA_Ready(AB.Ready  ),

  .ipB_SoP  (CD.SoP    ),
  .ipB_EoP  (CD.EoP    ),
  .ipB_Data (CD.Data   ),
  .ipB_Valid(CD.Valid  ),
  .opB_Ready(CD.Ready  ),

  .opSoP    (ABCD.SoP  ),
  .opEoP    (ABCD.EoP  ),
  .opData   (ABCD.Data ),
  .opValid  (ABCD.Valid),
  .ipReady  (ABCD.Ready)
);
//------------------------------------------------------------------------------

assign ABCD.Ready = 1;
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

