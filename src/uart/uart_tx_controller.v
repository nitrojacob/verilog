`timescale 1ns / 1ps
/**
 * UART Transmit controller FSM
 *
 * Parameter description
 * None
 *
 * Signal Description
 * CLK    - Clock to the module. Frequency same as baud rate
 * RST    - Reset input (Synchronous; 1 cycle active high; in CLK domain)
 * TX_START_REQ - Request line to start a UART TX
 * C_TC   - The terminal count input from the bit counter
 * TX_START_ACK - Ack line for TX_START_REQ
 * C_INC  - The increment control line to bit counter
 * C_RST  - Bit Counter Reset control
 * SR_LD  - Shift register's Parallel load command
 * SR_SE  - Shift register shift enable
 */
module uart_tx_controller(
    input CLK,
    input RST,
    input TX_START_REQ,
    input C_TC,
    output TX_START_ACK,
    output C_INC,
    output C_RST,
    output SR_LD,
    output SR_SE
    );
  parameter IDLE = 1'b0;
  parameter TXING = 1'b1;
  
  reg rSR_LD;
  reg rTX_START_ACK;
  reg state;
  
  assign C_RST = (state == IDLE)?1'b1:1'b0;
  assign C_INC = (state == IDLE)?1'b0:1'b1;
  assign SR_SE = (state == IDLE)?1'b0:1'b1;
  assign SR_LD = rSR_LD;
  assign TX_START_ACK = rTX_START_ACK;
  
  always @ (posedge CLK) begin
    if(RST == 1)
      state <= IDLE;
    else begin
      case(state)
        IDLE: begin
          if(TX_START_REQ == 1) begin
            rSR_LD <= 1;
            state <= TXING;
            rTX_START_ACK <= 1;
          end else begin
            rSR_LD <= 0;
            state <= IDLE;
            rTX_START_ACK <= 0;
          end
        end
        TXING:begin
          if(TX_START_REQ == 0)
            rTX_START_ACK <= 0;
          rSR_LD <= 0;
          if(C_TC == 1)
            state <= IDLE;
          else
            state <= TXING;
        end
      endcase
    end
  end
endmodule
