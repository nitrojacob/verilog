`timescale 1ns / 1ps
`include uart_rx.v
`include "../../src/uart/uart_tx.v"
/**
 * Provides an APB interface to UART
 * PCLK and MCLK must be synchronous and freq(PCLK) <= freq(MCLK)
 */
module uart(
    input MCLK, /* Higher frequency internal clock/ Module CLocK */
    input PCLK, /* Lower frequency aPb CLocK */
    input PRESETn,
    input PWRITE,
    input PADDR,
    input PWDATA,
    output PRDATA,
    input RX,
    output TX
    );
  reg [7:0] RegFile [2:0];
  wire RX_DV, CLR_RX_DV;
  wire RST;
  wire [7:0] rx_bus;
  
  assign RST = ~PRESETn;
  
  always @ posedge(PCLK) begin
    RegFile[0] <= (RX_DV)?rx_bus:RegFile[0];            /* RX Data */
    RegFile[1] <= (PWRITE & PSELx)?PDATA:RegFile[1];    /* TX Data */
    RegFile[2] <= RegFile[2];
  end
  
  always @ posedge(MCLK) begin
    CLR_RX_DV <= 
  
  uart_rx #(.exp(4), .overSampling(16), .baudRate(115200), .bits(8)) U1 (
    .RX(RX),
    .RST(RST),
    .CLK(MCLK),
    .Data(rx_bus),
    .DV(DV),
    .CLR_DV(CLR_DV)
    );
  uart_tx U2 (
    .DATA_IN(RegFile[1]),
    .CLK(MCLK),
    .RST(RST),
    .TX_START_REQ(DV),
    .TX_START_ACK(CLR_DV),
    .TX(TX)
    );

endmodule
