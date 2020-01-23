`timescale 1ns / 1ps
/**
 * Simple Pre-scaler Module
 *
 * Parameter description
 * I_freq     - Input frequency in Hz
 * O_freq     - Required output frequency in Hz
 *
 * Port description
 * CLK_i      - Input clock
 * RST        - Reset input (Synchronous, Active high for 1 clock)
 * CLK_o      - Clock output
 */
module prescaler #(parameter size = 10, parameter I_freq = 32000000, parameter O_freq = 460800)(
    input CLK_i,
    input RST,
    output CLK_o
    );
  reg [(size-1):0] Count;
  reg OutClk;
  reg [size:0] nCount;
  wire [32:0] zeros;
  
  assign CLK_o = OutClk;
  assign zeros = 0;
  
  always @(posedge CLK_i)
  begin
    if(RST == 1) begin
      Count <= 0;
      OutClk <= 0;
    end else begin
      nCount = Count + 1;
      Count <= (Count < (I_freq/O_freq/2))?nCount[(size-1):0]:zeros[(size-1):0];
      if(Count == (I_freq/O_freq/2))
        OutClk <= ~OutClk;
    end
  end
endmodule
