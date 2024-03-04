`timescale 1ns / 1ps
/**
 * Jacob Mathew
 * 23/7/2016
 *
 * Asynchronous or clock crossing fifo. Fifo writes are in write clock domain, and the
 * FIFO registers are clocked in the write domain clock. On the read side the registers
 * are just holding their values steadily, and not doing any transition on the read
 * clock edge. And with extra logics we must ensure that the registers don't change
 * their contents while they are accessed.
 *
 * To write data to FIFO,
 *  1. make sure full_o is deasserted.
 *  2. setup data.
 *  3. assert wr_i for 1 cycle of wrclk_i
 *
 * To read data from FIFO,
 *  1. assert rd_i for 1 cycle of rdclk_i (optionally, if you don't want to pipeline then de-assert it)
 *  2. wait for one cycle for the fifo to process the request
 *  3. data_o will be valid for the next edge of rdclk_i, if empty_o is de-asserted.
 *
 *                   +---\\---+
 *      full_o <-----|   //   |-------> empty_o
 *      data_i ----->|   \\   |-------> data_o
 *      wr_i   ----->|   //   |<------- rd_i
 *      wrclk_i----->|   \\   |<------- rdclk_i
                     |   //   |
 *                +->|   \\   |<-+
 *                |  +---//---+  |
 *                |              |
 *                |              |
 *        rst_i---+--------------+
 */
module async_fifo #(parameter FIFO_SZ=8, parameter WIDTH=8, parameter PTR_SZ=$clog2(FIFO_SZ))(
    input [WIDTH-1:0] data_i,
    output [WIDTH-1:0] data_o,
    input wr_i,
    input rd_i,
    output full_o,
    output empty_o,
    input rst_i,
    input wrclk_i,
    input rdclk_i
    );
  
  
  reg   [PTR_SZ-1:0]   rdptr_wrdom;
  reg   [PTR_SZ-1:0]   wrptr_rddom;
  wire  [PTR_SZ-1:0]   rdptr;
  wire  [PTR_SZ-1:0]   wrptr;
  wire  [PTR_SZ-1:0]   wrptr_next;
  
  wire                 wr_en;
  wire                 rd_en;
  wire                 fifo_full;
  wire                 fifo_empty;
  
  
  reg[WIDTH-1:0]  storage[FIFO_SZ-1:0];
  
  /* Synchronizer flop for read pointer in write clock domain */
  always @ (posedge wrclk_i)
  begin
    if(rst_i)
      rdptr_wrdom <= 0;
    else
      rdptr_wrdom <= rdptr;
  end
  
  /* Synchronizer flop for write pointer in read clock domain */
  always @ (posedge rdclk_i)
  begin
    if(rst_i)
      wrptr_rddom <= 0;
    else
      wrptr_rddom <= wrptr;
  end
  
  /* Writing to the FIFO */
  always @ (posedge wrclk_i)
  begin
    if(wr_en) begin
      storage[wrptr] <= data_i;
    end else begin
      storage[wrptr] <= storage[wrptr];
    end
  end

  /* Reading from the FIFO */
  assign data_o = rd_en?storage[rdptr]:{WIDTH-1{1'b0}};

  assign fifo_full = (wrptr_next == rdptr_wrdom);
  assign fifo_empty= (rdptr == wrptr_rddom);
  assign wr_en = wr_i & ~fifo_full;
  assign rd_en = rd_i & ~fifo_empty;
  assign full_o = fifo_full;
  assign empty_o = fifo_empty;
  
  gray_counter #(.WIDTH(PTR_SZ)) U1 (.clk_i(wrclk_i), .count_o(wrptr), .nextCount_o(wrptr_next), .rst_i(rst_i), .en_i(wr_en));
  gray_counter #(.WIDTH(PTR_SZ)) U2 (.clk_i(rdclk_i), .count_o(rdptr), .nextCount_o(          ), .rst_i(rst_i), .en_i(rd_en));

endmodule
