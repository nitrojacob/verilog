`timescale 1ns / 1ps
/**
 * Jacob Mathew
 * 29/06/2015
 *
 * JTAG TAP Controller 
 */
module tap_controller #(parameter IR_WIDTH = 6)(
    input TCK,
    input TMS,
    input TDI,
    input TRST,
    output TDO,
    output[(IR_WIDTH-1):0] IR,
    
    output SO,
    output LOAD_CHAIN,
    output STORE_CHAIN,
    input  SI
    );
  parameter TEST_RST = 4'b0000;
  parameter RT_IDLE  = 4'b0001;
  parameter SELEC_DR = 4'b0010;
  parameter SELEC_IR = 4'b0011;
  parameter CAPTR_DR = 4'b0100;
  parameter CAPTR_IR = 4'b0101;
  parameter SHIFT_DR = 4'b0110;
  parameter SHIFT_IR = 4'b0111;
  parameter EXIT1_DR = 4'b1000;
  parameter EXIT1_IR = 4'b1001;
  parameter PAUSE_DR = 4'b1010;
  parameter PAUSE_IR = 4'b1011;
  parameter EXIT2_DR = 4'b1100;
  parameter EXIT2_IR = 4'b1101;
  parameter UPDAT_DR = 4'b1110;
  parameter UPDAT_IR = 4'b1111;
  integer i;
  
  reg[3:0] state;
  reg[(IR_WIDTH-1):0] rIR_SR, rIR;
  reg rTDO;
  
  assign IR = rIR;
  assign SO = (state == SHIFT_DR)?TDI:SI;
  assign TDO = rTDO;
  
  always @ (state, SI, TDI, rIR_SR[IR_WIDTH-1]) begin
    if(state == SHIFT_IR) begin
      rTDO = rIR_SR[0];
    end else if(state == SHIFT_DR) begin
      rTDO = SI;
    end else begin
      rTDO = TDI;
    end
  end
  
  assign LOAD_CHAIN = (state == CAPTR_DR)?1'b1:1'b0;
  assign STORE_CHAIN = (state == UPDAT_DR)?1'b1:1'b0;
  
  always @ (posedge TCK) begin
    if(TRST == 1)
      state <= TEST_RST;
    else begin
      case(state)
        TEST_RST: begin
          if(TMS == 0)
            state <= RT_IDLE;
        end
        RT_IDLE: begin
          if(TMS == 1)
            state <= SELEC_DR;
        end
        SELEC_DR: begin
          if(TMS == 1)
            state <= SELEC_IR;
          else
            state <= CAPTR_DR;
        end
        SELEC_IR: begin
          if(TMS == 1)
            state <= TEST_RST;
          else
            state <= CAPTR_IR;
        end
        CAPTR_DR: begin
          if(TMS == 0)
            state <= SHIFT_DR;
          else
            state <= EXIT1_DR;
        end
        CAPTR_IR: begin
          rIR_SR <= 0;      /* Capture IR */
          if(TMS == 0)
            state <= SHIFT_IR;
          else
            state <= EXIT1_IR;
        end
        SHIFT_DR: begin
          if(TMS == 1)
            state <= EXIT1_DR;
        end
        SHIFT_IR: begin
          if(TMS == 1)
            state <= EXIT1_IR;
          else begin
            state <= SHIFT_IR;
            for(i= 0; i < IR_WIDTH-1; i = i+1)  /* Shift register */
              rIR_SR[i] <= rIR_SR[i+1];
            rIR_SR[IR_WIDTH-1] <= TDI;
          end
        end
        EXIT1_DR: begin
          if(TMS == 0)
            state <= PAUSE_DR;
          else
            state <= UPDAT_DR;
        end
        EXIT1_IR: begin
          if(TMS == 0)
            state <= PAUSE_IR;
          else
            state <= UPDAT_IR;
        end
        PAUSE_DR: begin
          if(TMS == 1)
            state <= EXIT2_DR;
        end
        PAUSE_IR: begin
          if(TMS == 1)
            state <= EXIT2_IR;
        end
        EXIT2_DR: begin
          if(TMS == 0)
            state <= SHIFT_DR;
          else
            state <= UPDAT_DR;
        end
        EXIT2_IR: begin
          if(TMS == 0)
            state <= SHIFT_IR;
          else
            state <= UPDAT_IR;
        end
        UPDAT_DR: begin
          if(TMS == 0)
            state <= RT_IDLE;
          else
            state <= SELEC_DR;
        end
        UPDAT_IR: begin
          rIR <= rIR_SR;      /* Update the IR */
          if(TMS == 0)
            state <= RT_IDLE;
          else
            state <= SELEC_DR;
        end
      endcase
    end
  end

endmodule
