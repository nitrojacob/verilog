`timescale 1ns / 1ps

module uart_tx(
    input [7:0] DATA_IN,
    input CLK,
    input RST,
    input TX_START_REQ,
    output TX_START_ACK,
    output TX
    );
  wire baudClk;
  wire SE;
  wire RST_b;
  wire C_TC;
  wire C_RST;
  wire C_INC;
  wire SR_LD;
  wire[9:0] DATA;
  
  assign DATA[9] = 1'b0;
  assign DATA[8:1] = DATA_IN;
  assign DATA[0] = 1'b1;
  prescaler #(.size(8), .I_freq(32000000), .O_freq(115200)) U1(.CLK_i(CLK), .RST(RST), .CLK_o(baudClk));
  shift_register #(.size(10)) U2(.CLK(baudClk), .SE_1(1'b1), .SE_2(SE), .SI(1'b1), .SO(TX), .PI(DATA), .LOAD(SR_LD));
  uart_tx_controller U3(.CLK(baudClk), .RST(RST_b), .TX_START_REQ(TX_START_REQ), .TX_START_ACK(TX_START_ACK), .C_TC(C_TC), .C_INC(C_INC), .C_RST(C_RST), .SR_LD(SR_LD), .SR_SE(SE));
  reset_latch U4 (.CLK_1(CLK), .CLK_2(baudClk), .IN(RST), .OUT(RST_b));
  counter #(.exp(4), .Width(10)) U5 (.CLK(baudClk), .RST(C_RST), .CE(C_INC), .TC(C_TC));
endmodule
