`timescale 1ns / 1ps

/**
 * A gray encoder implementation.
 */
module gray_encoder #(parameter WIDTH=8)(
    input [WIDTH-1:0] binary_i,
    output [WIDTH-1:0] gray_o
    );
  
  genvar i;
  
  wire [WIDTH-1:0] encoder_out;
  
  assign gray_o = encoder_out;
  
  for (i = 0; i < WIDTH-1; i = i + 1)
  begin: gray_expansion
    assign encoder_out[i] = binary_i[i] ^ binary_i[i+1];
  end
  assign encoder_out[WIDTH-1] = binary_i[WIDTH-1];

endmodule
