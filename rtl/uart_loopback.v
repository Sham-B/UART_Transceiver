`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2026 04:30:58 PM
// Design Name: 
// Module Name: uart_loopback
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


module uart_loopback(
    input clk, rst, start,
    input [7:0] tx_data,
    output [7:0] rx_data,
    output rx_done
    );
    wire tx;
    wire busy;
    parameter baud_rate= 9600;
    parameter clk_freq= 100000000;
    transmitter #(
    .baud_rate(baud_rate),
    .clk_freq(clk_freq)) txinst(
        .clk(clk),
        .rst(rst),
        .tx_start(start),
        .data_in(tx_data),
        .busy(busy),
        .tx(tx)
    );
    receiver #(
    .baud_rate(baud_rate),
    .clk_freq(clk_freq)) rxinst(
        .clk(clk),
        .rst(rst),
        .rx(tx),
        .data_out(rx_data),
        .rx_done(rx_done)
        );
endmodule
