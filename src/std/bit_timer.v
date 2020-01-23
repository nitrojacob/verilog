`timescale 1ns / 1ps
/**
 * A sub-bit timer implementation. The total bit duration is provided as parameter
 * 'duration'. The input HSel will select whether to count duration/2 or duration
 * cycles of clock before giving TC. There is no count enable pin. The counter will
 * start counting every CLK edge, once RST is de-asserted.
 *
 * Parameter description
 * duration   - No. of clocks per bit
 * exp        - 2^exp >= duration; This relation must be satisfied
 *
 * Port description
 * CLK        - The clock input
 * RST        - Reset input (Synchronous, active high for 1 cycle of CLK)
 * HSel       - Half bit select. If active the counter will only count duration/2
 *              clock cycles before activating TC
 * TC         - The termianl count output
 */
module bit_timer #(parameter exp = 2, parameter duration = 4)(
    input CLK,
    input RST,
    input HSel,
    output TC
    );
  //parameter duration = 2^oversampling;
  
  wire [31:0] zeros;
  
  reg[(exp-1):0] count;
  reg[exp:0] temp;  /* One extra bit is needed */
  reg rTC;
  
  assign zeros = 32'h0000_0000;
  
  always @(posedge CLK) begin
    if(RST == 1) begin
      count <= 0;
      rTC   <= 0;
    end else begin
      temp = count + 1;
      if(HSel == 1) begin
        count <= (temp >= (duration/2))?zeros[(exp-1):0]:temp[(exp-1):0];
        rTC <= (temp >= (duration/2))?1'b1:1'b0;
      end else begin
        count <= (temp >= duration)?zeros[(exp-1):0]:temp[(exp-1):0];
        rTC <= (temp >= duration)?1'b1:1'b0;
      end
    end
  end
  assign TC = rTC;
  
endmodule
