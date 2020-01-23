`timescale 1ns / 1ps
/**
 * Holds the signal coming in one clock domain(source) for atleast one clock cycle
 * in the second clock domain(destination). Useful if the source domain is of higher
 * frequency than the destination domain.
 *
 *          +-------------+
 *          |             |
 *    ----->|IN        OUT|------>
 *          |             |
 *    ----->|>CLK_1 CLK_2<|<------
 *          +-------------+
 */
module reset_latch(
    input CLK_1,  /* The faster clock */
    input CLK_2,  /* The slower clock */
    input IN,
    output OUT
    );

  wire clear;    /* Reverse Handshake */
  reg data;     /* Forward Handshake */
  reg rOUT;
  
  always @ (posedge CLK_1) begin
    if(IN == 1)
      data <= 1;
    else begin
      if(clear == 1)
        data <= 0;
      else
        data <= data;
    end
  end
  
  assign OUT = rOUT;
  assign clear = rOUT;
  
  always @ (posedge CLK_2) begin
    if(data == 1) begin
      rOUT <= 1;
    end else begin
      rOUT <= 0;
    end
  end

endmodule
