/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.12.1.454 */
/* Module Version: 7.5 */
/* C:\lscc\diamond\3.12\ispfpga\bin\nt64\scuba.exe -w -n FIFO -lang verilog -synth synplify -bus_exp 7 -bb -arch mg5a00 -type bram -wp 11 -rp 1010 -data_width 16 -rdata_width 16 -num_rows 4096 -writemodeA NORMAL -writemodeB NORMAL -resetmode SYNC -cascade -1  */
/* Fri May 06 16:03:07 2022 */


`timescale 1 ns / 1 ps
module FIFO (DataInA, DataInB, AddressA, AddressB, ClockA, ClockB, 
    ClockEnA, ClockEnB, WrA, WrB, ResetA, ResetB, QA, QB)/* synthesis NGD_DRC_MASK=1 */;
    input wire [15:0] DataInA;
    input wire [15:0] DataInB;
    input wire [11:0] AddressA;
    input wire [11:0] AddressB;
    input wire ClockA;
    input wire ClockB;
    input wire ClockEnA;
    input wire ClockEnB;
    input wire WrA;
    input wire WrB;
    input wire ResetA;
    input wire ResetB;
    output wire [15:0] QA;
    output wire [15:0] QB;

    wire scuba_vhi;
    wire scuba_vlo;

    VHI scuba_vhi_inst (.Z(scuba_vhi));

    DP16KB #(
      .CSDECODE_B  ( 3'b000),
      .CSDECODE_A  ( 3'b000),
      .WRITEMODE_B ("NORMAL"),
      .WRITEMODE_A ("NORMAL"),
      .GSR         ("DISABLED"),
      .RESETMODE   ("SYNC"),
      .REGMODE_B   ("NOREG"),
      .REGMODE_A   ("NOREG"),
      .DATA_WIDTH_B(4),
      .DATA_WIDTH_A(4)
    ) FIFO_0_0_3 (.DIA0(DataInA[0]), .DIA1(DataInA[1]), .DIA2(DataInA[2]), 
        .DIA3(DataInA[3]), .DIA4(scuba_vlo), .DIA5(scuba_vlo), .DIA6(scuba_vlo), 
        .DIA7(scuba_vlo), .DIA8(scuba_vlo), .DIA9(scuba_vlo), .DIA10(scuba_vlo), 
        .DIA11(scuba_vlo), .DIA12(scuba_vlo), .DIA13(scuba_vlo), .DIA14(scuba_vlo), 
        .DIA15(scuba_vlo), .DIA16(scuba_vlo), .DIA17(scuba_vlo), .ADA0(scuba_vlo), 
        .ADA1(scuba_vlo), .ADA2(AddressA[0]), .ADA3(AddressA[1]), .ADA4(AddressA[2]), 
        .ADA5(AddressA[3]), .ADA6(AddressA[4]), .ADA7(AddressA[5]), .ADA8(AddressA[6]), 
        .ADA9(AddressA[7]), .ADA10(AddressA[8]), .ADA11(AddressA[9]), .ADA12(AddressA[10]), 
        .ADA13(AddressA[11]), .CEA(ClockEnA), .CLKA(ClockA), .WEA(WrA), 
        .CSA0(scuba_vlo), .CSA1(scuba_vlo), .CSA2(scuba_vlo), .RSTA(ResetA), 
        .DIB0(DataInB[0]), .DIB1(DataInB[1]), .DIB2(DataInB[2]), .DIB3(DataInB[3]), 
        .DIB4(scuba_vlo), .DIB5(scuba_vlo), .DIB6(scuba_vlo), .DIB7(scuba_vlo), 
        .DIB8(scuba_vlo), .DIB9(scuba_vlo), .DIB10(scuba_vlo), .DIB11(scuba_vlo), 
        .DIB12(scuba_vlo), .DIB13(scuba_vlo), .DIB14(scuba_vlo), .DIB15(scuba_vlo), 
        .DIB16(scuba_vlo), .DIB17(scuba_vlo), .ADB0(scuba_vlo), .ADB1(scuba_vlo), 
        .ADB2(AddressB[0]), .ADB3(AddressB[1]), .ADB4(AddressB[2]), .ADB5(AddressB[3]), 
        .ADB6(AddressB[4]), .ADB7(AddressB[5]), .ADB8(AddressB[6]), .ADB9(AddressB[7]), 
        .ADB10(AddressB[8]), .ADB11(AddressB[9]), .ADB12(AddressB[10]), 
        .ADB13(AddressB[11]), .CEB(ClockEnB), .CLKB(ClockB), .WEB(WrB), 
        .CSB0(scuba_vlo), .CSB1(scuba_vlo), .CSB2(scuba_vlo), .RSTB(ResetB), 
        .DOA0(QA[0]), .DOA1(QA[1]), .DOA2(QA[2]), .DOA3(QA[3]), .DOA4(), 
        .DOA5(), .DOA6(), .DOA7(), .DOA8(), .DOA9(), .DOA10(), .DOA11(), 
        .DOA12(), .DOA13(), .DOA14(), .DOA15(), .DOA16(), .DOA17(), .DOB0(QB[0]), 
        .DOB1(QB[1]), .DOB2(QB[2]), .DOB3(QB[3]), .DOB4(), .DOB5(), .DOB6(), 
        .DOB7(), .DOB8(), .DOB9(), .DOB10(), .DOB11(), .DOB12(), .DOB13(), 
        .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="FIFO.lpc" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis CSDECODE_B="0b000" */
             /* synthesis CSDECODE_A="0b000" */
             /* synthesis WRITEMODE_B="NORMAL" */
             /* synthesis WRITEMODE_A="NORMAL" */
             /* synthesis GSR="DISABLED" */
             /* synthesis RESETMODE="SYNC" */
             /* synthesis REGMODE_B="NOREG" */
             /* synthesis REGMODE_A="NOREG" */
             /* synthesis DATA_WIDTH_B="4" */
             /* synthesis DATA_WIDTH_A="4" */;

    DP16KB #(
      .CSDECODE_B  ( 3'b000),
      .CSDECODE_A  ( 3'b000),
      .WRITEMODE_B ("NORMAL"),
      .WRITEMODE_A ("NORMAL"),
      .GSR         ("DISABLED"),
      .RESETMODE   ("SYNC"),
      .REGMODE_B   ("NOREG"),
      .REGMODE_A   ("NOREG"),
      .DATA_WIDTH_B(4),
      .DATA_WIDTH_A(4)
    ) FIFO_0_1_2 (.DIA0(DataInA[4]), .DIA1(DataInA[5]), .DIA2(DataInA[6]), 
        .DIA3(DataInA[7]), .DIA4(scuba_vlo), .DIA5(scuba_vlo), .DIA6(scuba_vlo), 
        .DIA7(scuba_vlo), .DIA8(scuba_vlo), .DIA9(scuba_vlo), .DIA10(scuba_vlo), 
        .DIA11(scuba_vlo), .DIA12(scuba_vlo), .DIA13(scuba_vlo), .DIA14(scuba_vlo), 
        .DIA15(scuba_vlo), .DIA16(scuba_vlo), .DIA17(scuba_vlo), .ADA0(scuba_vlo), 
        .ADA1(scuba_vlo), .ADA2(AddressA[0]), .ADA3(AddressA[1]), .ADA4(AddressA[2]), 
        .ADA5(AddressA[3]), .ADA6(AddressA[4]), .ADA7(AddressA[5]), .ADA8(AddressA[6]), 
        .ADA9(AddressA[7]), .ADA10(AddressA[8]), .ADA11(AddressA[9]), .ADA12(AddressA[10]), 
        .ADA13(AddressA[11]), .CEA(ClockEnA), .CLKA(ClockA), .WEA(WrA), 
        .CSA0(scuba_vlo), .CSA1(scuba_vlo), .CSA2(scuba_vlo), .RSTA(ResetA), 
        .DIB0(DataInB[4]), .DIB1(DataInB[5]), .DIB2(DataInB[6]), .DIB3(DataInB[7]), 
        .DIB4(scuba_vlo), .DIB5(scuba_vlo), .DIB6(scuba_vlo), .DIB7(scuba_vlo), 
        .DIB8(scuba_vlo), .DIB9(scuba_vlo), .DIB10(scuba_vlo), .DIB11(scuba_vlo), 
        .DIB12(scuba_vlo), .DIB13(scuba_vlo), .DIB14(scuba_vlo), .DIB15(scuba_vlo), 
        .DIB16(scuba_vlo), .DIB17(scuba_vlo), .ADB0(scuba_vlo), .ADB1(scuba_vlo), 
        .ADB2(AddressB[0]), .ADB3(AddressB[1]), .ADB4(AddressB[2]), .ADB5(AddressB[3]), 
        .ADB6(AddressB[4]), .ADB7(AddressB[5]), .ADB8(AddressB[6]), .ADB9(AddressB[7]), 
        .ADB10(AddressB[8]), .ADB11(AddressB[9]), .ADB12(AddressB[10]), 
        .ADB13(AddressB[11]), .CEB(ClockEnB), .CLKB(ClockB), .WEB(WrB), 
        .CSB0(scuba_vlo), .CSB1(scuba_vlo), .CSB2(scuba_vlo), .RSTB(ResetB), 
        .DOA0(QA[4]), .DOA1(QA[5]), .DOA2(QA[6]), .DOA3(QA[7]), .DOA4(), 
        .DOA5(), .DOA6(), .DOA7(), .DOA8(), .DOA9(), .DOA10(), .DOA11(), 
        .DOA12(), .DOA13(), .DOA14(), .DOA15(), .DOA16(), .DOA17(), .DOB0(QB[4]), 
        .DOB1(QB[5]), .DOB2(QB[6]), .DOB3(QB[7]), .DOB4(), .DOB5(), .DOB6(), 
        .DOB7(), .DOB8(), .DOB9(), .DOB10(), .DOB11(), .DOB12(), .DOB13(), 
        .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="FIFO.lpc" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis CSDECODE_B="0b000" */
             /* synthesis CSDECODE_A="0b000" */
             /* synthesis WRITEMODE_B="NORMAL" */
             /* synthesis WRITEMODE_A="NORMAL" */
             /* synthesis GSR="DISABLED" */
             /* synthesis RESETMODE="SYNC" */
             /* synthesis REGMODE_B="NOREG" */
             /* synthesis REGMODE_A="NOREG" */
             /* synthesis DATA_WIDTH_B="4" */
             /* synthesis DATA_WIDTH_A="4" */;

    DP16KB #(
      .CSDECODE_B  ( 3'b000),
      .CSDECODE_A  ( 3'b000),
      .WRITEMODE_B ("NORMAL"),
      .WRITEMODE_A ("NORMAL"),
      .GSR         ("DISABLED"),
      .RESETMODE   ("SYNC"),
      .REGMODE_B   ("NOREG"),
      .REGMODE_A   ("NOREG"),
      .DATA_WIDTH_B(4),
      .DATA_WIDTH_A(4)
    ) FIFO_0_2_1 (.DIA0(DataInA[8]), .DIA1(DataInA[9]), .DIA2(DataInA[10]), 
        .DIA3(DataInA[11]), .DIA4(scuba_vlo), .DIA5(scuba_vlo), .DIA6(scuba_vlo), 
        .DIA7(scuba_vlo), .DIA8(scuba_vlo), .DIA9(scuba_vlo), .DIA10(scuba_vlo), 
        .DIA11(scuba_vlo), .DIA12(scuba_vlo), .DIA13(scuba_vlo), .DIA14(scuba_vlo), 
        .DIA15(scuba_vlo), .DIA16(scuba_vlo), .DIA17(scuba_vlo), .ADA0(scuba_vlo), 
        .ADA1(scuba_vlo), .ADA2(AddressA[0]), .ADA3(AddressA[1]), .ADA4(AddressA[2]), 
        .ADA5(AddressA[3]), .ADA6(AddressA[4]), .ADA7(AddressA[5]), .ADA8(AddressA[6]), 
        .ADA9(AddressA[7]), .ADA10(AddressA[8]), .ADA11(AddressA[9]), .ADA12(AddressA[10]), 
        .ADA13(AddressA[11]), .CEA(ClockEnA), .CLKA(ClockA), .WEA(WrA), 
        .CSA0(scuba_vlo), .CSA1(scuba_vlo), .CSA2(scuba_vlo), .RSTA(ResetA), 
        .DIB0(DataInB[8]), .DIB1(DataInB[9]), .DIB2(DataInB[10]), .DIB3(DataInB[11]), 
        .DIB4(scuba_vlo), .DIB5(scuba_vlo), .DIB6(scuba_vlo), .DIB7(scuba_vlo), 
        .DIB8(scuba_vlo), .DIB9(scuba_vlo), .DIB10(scuba_vlo), .DIB11(scuba_vlo), 
        .DIB12(scuba_vlo), .DIB13(scuba_vlo), .DIB14(scuba_vlo), .DIB15(scuba_vlo), 
        .DIB16(scuba_vlo), .DIB17(scuba_vlo), .ADB0(scuba_vlo), .ADB1(scuba_vlo), 
        .ADB2(AddressB[0]), .ADB3(AddressB[1]), .ADB4(AddressB[2]), .ADB5(AddressB[3]), 
        .ADB6(AddressB[4]), .ADB7(AddressB[5]), .ADB8(AddressB[6]), .ADB9(AddressB[7]), 
        .ADB10(AddressB[8]), .ADB11(AddressB[9]), .ADB12(AddressB[10]), 
        .ADB13(AddressB[11]), .CEB(ClockEnB), .CLKB(ClockB), .WEB(WrB), 
        .CSB0(scuba_vlo), .CSB1(scuba_vlo), .CSB2(scuba_vlo), .RSTB(ResetB), 
        .DOA0(QA[8]), .DOA1(QA[9]), .DOA2(QA[10]), .DOA3(QA[11]), .DOA4(), 
        .DOA5(), .DOA6(), .DOA7(), .DOA8(), .DOA9(), .DOA10(), .DOA11(), 
        .DOA12(), .DOA13(), .DOA14(), .DOA15(), .DOA16(), .DOA17(), .DOB0(QB[8]), 
        .DOB1(QB[9]), .DOB2(QB[10]), .DOB3(QB[11]), .DOB4(), .DOB5(), .DOB6(), 
        .DOB7(), .DOB8(), .DOB9(), .DOB10(), .DOB11(), .DOB12(), .DOB13(), 
        .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="FIFO.lpc" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis CSDECODE_B="0b000" */
             /* synthesis CSDECODE_A="0b000" */
             /* synthesis WRITEMODE_B="NORMAL" */
             /* synthesis WRITEMODE_A="NORMAL" */
             /* synthesis GSR="DISABLED" */
             /* synthesis RESETMODE="SYNC" */
             /* synthesis REGMODE_B="NOREG" */
             /* synthesis REGMODE_A="NOREG" */
             /* synthesis DATA_WIDTH_B="4" */
             /* synthesis DATA_WIDTH_A="4" */;

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    DP16KB #(
      .CSDECODE_B  ( 3'b000),
      .CSDECODE_A  ( 3'b000),
      .WRITEMODE_B ("NORMAL"),
      .WRITEMODE_A ("NORMAL"),
      .GSR         ("DISABLED"),
      .RESETMODE   ("SYNC"),
      .REGMODE_B   ("NOREG"),
      .REGMODE_A   ("NOREG"),
      .DATA_WIDTH_B(4),
      .DATA_WIDTH_A(4)
    ) FIFO_0_3_0 (.DIA0(DataInA[12]), .DIA1(DataInA[13]), .DIA2(DataInA[14]), 
        .DIA3(DataInA[15]), .DIA4(scuba_vlo), .DIA5(scuba_vlo), .DIA6(scuba_vlo), 
        .DIA7(scuba_vlo), .DIA8(scuba_vlo), .DIA9(scuba_vlo), .DIA10(scuba_vlo), 
        .DIA11(scuba_vlo), .DIA12(scuba_vlo), .DIA13(scuba_vlo), .DIA14(scuba_vlo), 
        .DIA15(scuba_vlo), .DIA16(scuba_vlo), .DIA17(scuba_vlo), .ADA0(scuba_vlo), 
        .ADA1(scuba_vlo), .ADA2(AddressA[0]), .ADA3(AddressA[1]), .ADA4(AddressA[2]), 
        .ADA5(AddressA[3]), .ADA6(AddressA[4]), .ADA7(AddressA[5]), .ADA8(AddressA[6]), 
        .ADA9(AddressA[7]), .ADA10(AddressA[8]), .ADA11(AddressA[9]), .ADA12(AddressA[10]), 
        .ADA13(AddressA[11]), .CEA(ClockEnA), .CLKA(ClockA), .WEA(WrA), 
        .CSA0(scuba_vlo), .CSA1(scuba_vlo), .CSA2(scuba_vlo), .RSTA(ResetA), 
        .DIB0(DataInB[12]), .DIB1(DataInB[13]), .DIB2(DataInB[14]), .DIB3(DataInB[15]), 
        .DIB4(scuba_vlo), .DIB5(scuba_vlo), .DIB6(scuba_vlo), .DIB7(scuba_vlo), 
        .DIB8(scuba_vlo), .DIB9(scuba_vlo), .DIB10(scuba_vlo), .DIB11(scuba_vlo), 
        .DIB12(scuba_vlo), .DIB13(scuba_vlo), .DIB14(scuba_vlo), .DIB15(scuba_vlo), 
        .DIB16(scuba_vlo), .DIB17(scuba_vlo), .ADB0(scuba_vlo), .ADB1(scuba_vlo), 
        .ADB2(AddressB[0]), .ADB3(AddressB[1]), .ADB4(AddressB[2]), .ADB5(AddressB[3]), 
        .ADB6(AddressB[4]), .ADB7(AddressB[5]), .ADB8(AddressB[6]), .ADB9(AddressB[7]), 
        .ADB10(AddressB[8]), .ADB11(AddressB[9]), .ADB12(AddressB[10]), 
        .ADB13(AddressB[11]), .CEB(ClockEnB), .CLKB(ClockB), .WEB(WrB), 
        .CSB0(scuba_vlo), .CSB1(scuba_vlo), .CSB2(scuba_vlo), .RSTB(ResetB), 
        .DOA0(QA[12]), .DOA1(QA[13]), .DOA2(QA[14]), .DOA3(QA[15]), .DOA4(), 
        .DOA5(), .DOA6(), .DOA7(), .DOA8(), .DOA9(), .DOA10(), .DOA11(), 
        .DOA12(), .DOA13(), .DOA14(), .DOA15(), .DOA16(), .DOA17(), .DOB0(QB[12]), 
        .DOB1(QB[13]), .DOB2(QB[14]), .DOB3(QB[15]), .DOB4(), .DOB5(), .DOB6(), 
        .DOB7(), .DOB8(), .DOB9(), .DOB10(), .DOB11(), .DOB12(), .DOB13(), 
        .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="FIFO.lpc" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis CSDECODE_B="0b000" */
             /* synthesis CSDECODE_A="0b000" */
             /* synthesis WRITEMODE_B="NORMAL" */
             /* synthesis WRITEMODE_A="NORMAL" */
             /* synthesis GSR="DISABLED" */
             /* synthesis RESETMODE="SYNC" */
             /* synthesis REGMODE_B="NOREG" */
             /* synthesis REGMODE_A="NOREG" */
             /* synthesis DATA_WIDTH_B="4" */
             /* synthesis DATA_WIDTH_A="4" */;



    // exemplar begin
    // exemplar attribute FIFO_0_0_3 MEM_LPC_FILE FIFO.lpc
    // exemplar attribute FIFO_0_0_3 MEM_INIT_FILE 
    // exemplar attribute FIFO_0_0_3 CSDECODE_B 0b000
    // exemplar attribute FIFO_0_0_3 CSDECODE_A 0b000
    // exemplar attribute FIFO_0_0_3 WRITEMODE_B NORMAL
    // exemplar attribute FIFO_0_0_3 WRITEMODE_A NORMAL
    // exemplar attribute FIFO_0_0_3 GSR DISABLED
    // exemplar attribute FIFO_0_0_3 RESETMODE SYNC
    // exemplar attribute FIFO_0_0_3 REGMODE_B NOREG
    // exemplar attribute FIFO_0_0_3 REGMODE_A NOREG
    // exemplar attribute FIFO_0_0_3 DATA_WIDTH_B 4
    // exemplar attribute FIFO_0_0_3 DATA_WIDTH_A 4
    // exemplar attribute FIFO_0_1_2 MEM_LPC_FILE FIFO.lpc
    // exemplar attribute FIFO_0_1_2 MEM_INIT_FILE 
    // exemplar attribute FIFO_0_1_2 CSDECODE_B 0b000
    // exemplar attribute FIFO_0_1_2 CSDECODE_A 0b000
    // exemplar attribute FIFO_0_1_2 WRITEMODE_B NORMAL
    // exemplar attribute FIFO_0_1_2 WRITEMODE_A NORMAL
    // exemplar attribute FIFO_0_1_2 GSR DISABLED
    // exemplar attribute FIFO_0_1_2 RESETMODE SYNC
    // exemplar attribute FIFO_0_1_2 REGMODE_B NOREG
    // exemplar attribute FIFO_0_1_2 REGMODE_A NOREG
    // exemplar attribute FIFO_0_1_2 DATA_WIDTH_B 4
    // exemplar attribute FIFO_0_1_2 DATA_WIDTH_A 4
    // exemplar attribute FIFO_0_2_1 MEM_LPC_FILE FIFO.lpc
    // exemplar attribute FIFO_0_2_1 MEM_INIT_FILE 
    // exemplar attribute FIFO_0_2_1 CSDECODE_B 0b000
    // exemplar attribute FIFO_0_2_1 CSDECODE_A 0b000
    // exemplar attribute FIFO_0_2_1 WRITEMODE_B NORMAL
    // exemplar attribute FIFO_0_2_1 WRITEMODE_A NORMAL
    // exemplar attribute FIFO_0_2_1 GSR DISABLED
    // exemplar attribute FIFO_0_2_1 RESETMODE SYNC
    // exemplar attribute FIFO_0_2_1 REGMODE_B NOREG
    // exemplar attribute FIFO_0_2_1 REGMODE_A NOREG
    // exemplar attribute FIFO_0_2_1 DATA_WIDTH_B 4
    // exemplar attribute FIFO_0_2_1 DATA_WIDTH_A 4
    // exemplar attribute FIFO_0_3_0 MEM_LPC_FILE FIFO.lpc
    // exemplar attribute FIFO_0_3_0 MEM_INIT_FILE 
    // exemplar attribute FIFO_0_3_0 CSDECODE_B 0b000
    // exemplar attribute FIFO_0_3_0 CSDECODE_A 0b000
    // exemplar attribute FIFO_0_3_0 WRITEMODE_B NORMAL
    // exemplar attribute FIFO_0_3_0 WRITEMODE_A NORMAL
    // exemplar attribute FIFO_0_3_0 GSR DISABLED
    // exemplar attribute FIFO_0_3_0 RESETMODE SYNC
    // exemplar attribute FIFO_0_3_0 REGMODE_B NOREG
    // exemplar attribute FIFO_0_3_0 REGMODE_A NOREG
    // exemplar attribute FIFO_0_3_0 DATA_WIDTH_B 4
    // exemplar attribute FIFO_0_3_0 DATA_WIDTH_A 4
    // exemplar end

endmodule
