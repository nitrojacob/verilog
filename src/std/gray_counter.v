`timescale 1ns / 1ps
/**
 * Gray up counter. The output is synchronised; and the delay from any input to any output
 * is one clock cycle.
 */
module gray_counter#(WIDTH=8)(
    input clk_i,
    output [WIDTH-1:0] count_o,
    output [WIDTH-1:0] nextCount_o,
    input rst_i,
    input en_i
    );
    wire [WIDTH-1:0] binCount_out;
    wire [WIDTH-1:0] nextCount_binary;
    wire [WIDTH-1:0] count_w;
    wire [WIDTH-1:0] nextCount_w;
    reg  [WIDTH-1:0] count_r;
    reg  [WIDTH-1:0] nextCount_r;
    
    assign count_o = count_r;
    assign nextCount_o = nextCount_r;
    assign nextCount_binary = binCount_out + 1;
    
    always @ (posedge clk_i)
    begin
      if(rst_i) begin
        count_r <= 0;
        nextCount_r <= 1;
      end else begin
        if(en_i)begin
          count_r <= count_w;
          nextCount_r <= nextCount_w;
        end else begin
          count_r <= count_r;
          nextCount_r <= nextCount_r;
        end
      end
    end
    
    gray_encoder #(.WIDTH(WIDTH)) U1 (.binary_i(binCount_out), .gray_o(count_w));
    gray_encoder #(.WIDTH(WIDTH)) U2 (.binary_i(nextCount_binary), .gray_o(nextCount_w));
    counter      #(.WIDTH(WIDTH), .RESET_VAL(1)) U3 (.CLK(clk_i), .CE(en_i), .RST(rst_i), .count(binCount_out));

endmodule
