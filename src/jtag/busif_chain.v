`timescale 1ns / 1ps
/**
 * Jacob Mathew
 * 24/02/2024
 * JTAG Scan chain to interface with the system debug module.
 * Clocked with both the SoC clock and Debug clock.
 * Internal clock domain crossing fifo added.
 */
module busif_chain #(
    parameter RADDR_WIDTH=12,
    parameter RDATA_WIDTH=32
    )(
    input clk_i,    /*SoC clock*/
    input rst_i,    /*SoC reset*/
    input TCK,      /*JTAG Clock*/
    input STORE_CHAIN,
    input LOAD_CHAIN,
    input SEL_CHAIN,
    input SI,
    output SO,
    output [RADDR_WIDTH-1:0] addr_o,
    output [RDATA_WIDTH-1:0] data_o,
    input [RDATA_WIDTH-1:0] data_i,
    output wr_o
    );
    localparam WIDTH = RADDR_WIDTH+RDATA_WIDTH+2;
    /*Chain Structure is [address(RADDR_WIDTH)|data(32bits)|op(2bits)]*/
    reg[WIDTH-1:0] chain;
    reg[RADDR_WIDTH-1:0] addr_r;
    reg[RDATA_WIDTH-1:0] data_r;
    reg wr_r;
    
    wire[RDATA_WIDTH-1:0] data_s;
    
    integer i;
  
    assign SO = chain[0];
  
    always @ (posedge TCK) begin
        if(SEL_CHAIN == 1)begin
            if(LOAD_CHAIN == 1) begin
                chain <= {chain[WIDTH-1:RDATA_WIDTH+2], data_s, 2'b00};
            end else if(STORE_CHAIN == 1) begin
                addr_r <= chain[WIDTH-1:RDATA_WIDTH+2];
                data_r <= chain[RDATA_WIDTH+2-1:2];
                wr_r <= 1;
            end else begin
                for(i=0; i<WIDTH-1; i=i+1)
                    chain[i] <= chain[i+1];
                chain[WIDTH-1] <= SI;
            end
        end else begin
            chain <= chain;
        end
    end
    
    async_fifo #(.WIDTH(RADDR_WIDTH+RDATA_WIDTH), .FIFO_SZ(2)) A_FIFO(.data_i({addr_r, data_r}), .data_o({addr_o, data_o}), .wr_i(wr_r), .full_o(wr_o), .wrclk_i(TCK), .rdclk_i(clk_i), .rst_i(rst_i), .rd_i(1'b1));
    async_fifo #(.WIDTH(RDATA_WIDTH), .FIFO_SZ(2)) D_FIFO(.data_i(data_i), .data_o(data_s), .wr_i(wr_r), .wrclk_i(clk_i), .rdclk_i(TCK), .rst_i(rst_i), .rd_i(1'b1)); /*TODO*/
    
endmodule
