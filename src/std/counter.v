`timescale 1ns / 1ps
/**
 * Synchronous counter modelled similar to 74193
 *
 * Parameter Description
 * Width    - The no of states of the counter
 * exp      - 2^exp >= Width; This relation should be satisfied
 *            exp is the no of flops to be used for the implementation
 *
 * Port Description
 * CLK      - Clock input
 * RST      - Reset input (Synchronous; Active High for one CLK cycle)
 * CE       - Count Enable. The Counter state changes only if this pin is active
 * TC       - The terminal count. Combinationally dependent on Count and CE 
 */
module counter #(parameter exp = 3, parameter Width = 8 ) (
    input CLK,
    input RST,
    input CE,
    output TC
    );

  reg[exp-1:0] Count;
  wire wTC;
  reg[exp:0] temp;
  
  assign TC = wTC & CE;
  assign wTC = (Count == Width-1)?1'b1:1'b0;
  
  always @ (posedge CLK) begin
    if(RST == 0) begin
      if(CE == 1)
        temp = Count + 1;
      else
        temp = Count;
      Count <= (temp[exp-1] < Width)?temp[exp-1:0]:0;
    end else begin
      Count <= 0;
    end
  end
endmodule
