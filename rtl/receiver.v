`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2026 07:25:18 PM
// Design Name: 
// Module Name: receiver
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


module receiver(
    input rx,
    input clk,
    input rst,
    
    output reg [7:0] data_out,
    output reg rx_done,
    output reg [13:0] baud_cnt,   // as these are registers 
    output reg [2:0] bit_cnt,
    output reg [7:0] data_reg,
    output reg [1:0] state
    );
   
    parameter baud_rate= 9600;
    parameter clk_freq= 100000000;
    parameter baud_div= clk_freq/baud_rate;
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;
    always @(posedge clk) begin
    if(rst)begin
        data_out<=0;
        data_reg<=0;
        baud_cnt<=0;
        bit_cnt<=0;
        rx_done<=0;
        state<=IDLE;
     end else begin
        case(state)
        IDLE:begin 
            rx_done<=0; 
            if(!rx)begin 
                state<=START;
                baud_cnt<=0;
           end  
         end
         START:begin
               if (baud_cnt==(baud_div/2) - 1)begin
                    if(rx==0) begin 
                       baud_cnt<=0;
                       bit_cnt<=0;
                       state<=DATA;
                    end else begin
                        state<=IDLE;
                        baud_cnt<=0;
               end end else begin
                   baud_cnt<=baud_cnt+1;
               end end
         DATA:begin
              if(baud_cnt==baud_div-1)begin
                   data_reg[bit_cnt]<=rx;
                   if(bit_cnt==7) begin
                       state<=STOP;
                       baud_cnt<=0;
                   end else begin
                       bit_cnt<=bit_cnt+1;
                       baud_cnt<=0;
                   end
               end else begin
                    baud_cnt<=baud_cnt+1;
               end end
        STOP: begin
              if(baud_cnt==baud_div-1)begin
                   baud_cnt<=0;
                   state<=IDLE;          
                   if(rx) begin
                       data_out<=data_reg;
                       rx_done<=1;
                   end
              end else begin
                   baud_cnt<=baud_cnt+1;
              end
        end 
         endcase
     end   //to close  if(rst) else block
     end   // to close always block
   endmodule