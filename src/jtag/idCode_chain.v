`timescale 1ns / 1ps
/**
 * Simple IDCODE type chain, whose value can be specified as the parameter
 *
 * Paramters
 * WIDTH  - Width of the Data register (in bits)
 * VALUE  - The value to be loaded to the DR chain
 *
 * Ports
 * SI     - Serial input to the chain
 * LOAD_CHAIN - Pulse signal on this line will load the chain with the value
 *              specified as parameter VALUE
 * SEL_CHAIN  - The chain will accept other signals only if this line is active
 * CLK    - The shift clock
 * SO     - Serial output from the chain
 */
module idCode_chain #(parameter WIDTH = 8, parameter VALUE = 8'ha5)(
    input SI,
    input LOAD_CHAIN,
    input SEL_CHAIN,
    input CLK,
    output SO
    );
  reg[WIDTH-1:0] chain;
  integer i;
  
  assign SO = chain[0];
  
  always @ (posedge CLK) begin
    if(SEL_CHAIN == 1)begin
      if(LOAD_CHAIN == 1) begin
        chain <= VALUE;
      end else begin
        for(i=0; i<WIDTH-1; i=i+1)
          chain[i] <= chain[i+1];
        chain[WIDTH-1] <= SI;
      end
    end else begin
      chain <= chain;
    end
  end
endmodule
