`timescale 1ns / 1ps

/**
 * Parameter Description
 * bits         - The number of information bits in the package (bits excluding start/stop)
 * baudRate     - The required baud rate for the communication
 * overSampling - The number of sample points to be taken in a bit/baud time.
 *                Higher sample rates are more tolerant to differences in frequencies
 * exp          - overSampling = 2^exp. This relation should be maintained
 *
 * Port Description
 * RX           - The serial receive input
 * RST          - Module reset signal(synchronous reset)
 * CLK          - Input clock to the module
 * Data         - The received data
 * DV           - Data Valid indicator
 */
module uart_rx #(parameter exp = 4, parameter overSampling = 16, parameter baudRate = 115200, parameter bits = 8)(
    input RX,
    input RST,
    input CLK,
    input CLR_DV,
    output [(bits-1):0] Data,
    output DV
    );
  wire Timer_TC, wTimer_HSel, Timer_RST;
  wire baudClk;
  wire Counter_RST, Counter_TC;
  wire SR_SE;
  wire[(bits-1):0]SR_PO;
  wire LF_RST;
  wire [31:0] ones; /* Dummy */

  reg[(bits-1):0] rSR_PO;

  assign Data = rSR_PO;
  assign ones = 32'hffff_ffff;  /* Dummy */
  
  always @ (posedge baudClk) begin
    if(DV == 1)
      rSR_PO <= SR_PO;
    else
      rSR_PO <= rSR_PO;
  end
  
  prescaler #(.size(4), .I_freq(32000000), .O_freq(baudRate*overSampling)) U3(.CLK_i(CLK), .RST(RST), .CLK_o(baudClk));
  reset_latch U6(.CLK_1(CLK), .CLK_2(baudClk), .IN(RST), .OUT(LF_RST));
  counter #(.Width(bits)) U1(.TC(Counter_TC), .CLK(baudClk), .CE(Timer_TC), .RST(Counter_RST));
  uart_rx_controller U2(.RX(RX), .RST(LF_RST), .CLK(baudClk), .Timer_TC(Timer_TC), .Counter_TC(Counter_TC), .Timer_HSel(wTimer_HSel), .Timer_RST(Timer_RST), .Counter_RST(Counter_RST), .SR_SE(SR_SE), .DV(DV), .CLR_DV(CLR_DV));
  bit_timer #(.exp(exp), .duration(overSampling)) U4(.CLK(baudClk), .RST(Timer_RST), .HSel(wTimer_HSel), .TC(Timer_TC));
  shift_register #(.size(bits)) U5 (.CLK(baudClk), .SE_1(SR_SE), .SE_2(Timer_TC), .SI(RX), .PO(SR_PO), .LOAD(1'b0), .PI(ones[(bits-1):0]));

endmodule
