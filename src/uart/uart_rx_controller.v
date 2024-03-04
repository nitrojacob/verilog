`timescale 1ns / 1ps
/**
 * FSM for the UART receiver
 */
module uart_rx_controller(
    input RX,
    input RST,
    input CLK,
    input Timer_TC,
    input Counter_TC,
    input CLR_DV,
    output Timer_HSel,
    output Timer_RST,
    output Counter_RST,
    output SR_SE,
    output DV
    );

  parameter IDLE  = 2'b00;
  parameter START = 2'b01;
  parameter RECV  = 2'b10;
  parameter RXCMP = 2'b11;

  reg[1:0] state;
  reg rDV;
  
  assign Timer_HSel   = (state == START)?1'b1:1'b0;
  assign Timer_RST    = (state == IDLE)?1'b1:1'b0;
  assign Counter_RST  = (state == RECV)?1'b0:1'b1;
  assign SR_SE        = (state == RECV)?1'b1:1'b0;
  assign DV           = rDV;
  
  always @ (posedge CLK)
  begin
    if(RST == 1)begin
      state <= IDLE;
      rDV   <= 0;
    end
    else begin
      case(state)
        IDLE:
          begin
            if(RX == 0) begin
              state <= START;
            end else if (CLR_DV == 1) begin
              rDV <= 0;
            end
          end
        START:  /* Start bit already detected. Stay on this state until middle of the start bit */
          begin
            if(RX == 0 && Timer_TC == 1) begin
              state <= RECV;
              rDV   <= 0;   /* Data is no longer valid */
            end else if(RX == 1) begin
              state <= IDLE;
            end else begin
              state <= START;
              if(CLR_DV == 1)
                rDV <= 0;
            end
          end
        RECV:   /* Shift enable in the middle of the bit, as long as Counter_TC == 0 */
          begin
            if(Counter_TC == 1)begin
              state <= RXCMP;
            end else begin
              state <= RECV;
            end
          end
        RXCMP:  /* Wait till the middle of the stop bit, and then transition to the IDLE state */
          if(Timer_TC == 1)begin
            state <= IDLE;
            rDV   <= 1;
          end
      endcase
    end
  end
endmodule
