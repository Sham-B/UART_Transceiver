`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2026 02:47:58 PM
// Design Name: 
// Module Name: transmitter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module transmitter(
    input clk,
    input rst,
    input tx_start,
    input  [7:0] data_in,
    output reg tx,
    output wire busy,
    output reg [7:0] data_reg,
    output reg [13:0] baud_cnt,
    output reg [2:0] bit_cnt,
    output reg [1:0] state
    );
    parameter baud_rate=9600; 
    parameter clk_freq= 100000000;
    parameter baud_div = clk_freq / baud_rate;
    
    localparam IDLE=2'b00;
    localparam START=2'b01;
    localparam DATA=2'b10;
    localparam STOP=2'b11;
    assign busy = (state != IDLE);
    always @(posedge clk) begin
    if(rst) begin
    bit_cnt<=0;
    data_reg<=0;
    baud_cnt<=0;
    state<=IDLE;
    tx<= 1'b1;
    end
    else begin
    case(state)
    IDLE: begin baud_cnt<=0;  if(tx_start) begin data_reg<=data_in; state<=START; end end
    START: begin tx<=0;  if(baud_cnt==baud_div-1)begin baud_cnt<=0; state<=DATA; bit_cnt<=0; end
                 else begin baud_cnt<=baud_cnt+1; end end
    DATA: begin tx <= data_reg[bit_cnt];        
            if(baud_cnt==baud_div-1) begin baud_cnt<=0; 
                if(bit_cnt==7) begin state<=STOP; end
                else begin  bit_cnt<=bit_cnt+1;  end end
            else begin baud_cnt<= baud_cnt+1; end 
            end
    STOP:  begin tx<=1; bit_cnt<=0; if(baud_cnt==baud_div-1)begin  baud_cnt<=0; tx<=1; state<=IDLE; end
                  else begin baud_cnt<=baud_cnt+1; end end

    endcase
    end
    end
endmodule
