`timescale 1ns / 1ps
/**
 * Shift register module
 *
 * Parameter description
 * size   - The size(no. of cells) of the shift register
 *
 * Port description
 * CLK    - Input clock
 * LOAD   - Loads the parallel input in PI[] to the shift register
 * SE_1   - Shift Enable 1
 * SE_2   - Shift Enable 2. SE_1 and SE_2 are AND-ed together to generate shift enable
 *          for the shift register
 * SI     - Serial input
 * PI     - Parallel input
 * PO     - Parallel output
 * SO     - Serial output
 */
module shift_register#(parameter size = 9)(
    input CLK,
    input LOAD,
    input SE_1,
    input SE_2,
    input SI,
    input [(size-1):0] PI,
    output [(size-1):0] PO,
    output SO
    );
  reg[(size-1):0] buffer;
  integer bitfield;
  
  assign PO = buffer;
  assign SO = buffer[size-1];
  always @ (posedge CLK) begin
    if(LOAD == 1) begin
      buffer <= PI;
    end else if((SE_1 & SE_2) == 1) begin
      for(bitfield = (size-1); bitfield > 0; bitfield = bitfield - 1)
        buffer[bitfield] <= buffer[bitfield - 1];
      buffer[0] <= SI;
    end
  end
endmodule
