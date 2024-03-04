`timescale 1ns / 1ps
/**
 * Synchronous counter modelled similar to 74193
 *
 * Parameter Description
 * Width    - Width of the counter (No of flip-flops)
 *
 * Port Description
 * CLK      - Clock input
 * RST      - Reset input (Synchronous; Active High for one CLK cycle)
 * CE       - Count Enable. The Counter state changes only if this pin is active
 * TC       - The terminal count. Combinationally dependent on Count and CE 
 */
module counter #(parameter WIDTH = 3, parameter RESET_VAL = 0 ) (
    input CLK,
    input RST,
    input CE,
    output TC,
    output [WIDTH-1:0] count
    );

  reg[WIDTH-1:0] count_r;
  wire wTC;
  wire[WIDTH:0] nextCount;
  
  assign TC = wTC & CE;
  assign wTC = &count_r;
  assign count = count_r;
  assign nextCount = count_r + 1;
  
  always @ (posedge CLK) begin
    if(RST == 0) begin
      if(CE == 1)
        count_r <= nextCount[WIDTH-1:0];
      else
        count_r <= count_r;
    end else begin
      count_r <= RESET_VAL;
    end
  end
endmodule
