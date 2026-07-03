`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2026 06:57:19 PM
// Design Name: 
// Module Name: tb_receiver
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


module tb_receiver();
reg clk = 0;
reg rst = 1;
reg rx  = 1;

wire [7:0] data_out;
wire rx_done;
wire [1:0] state;
wire [13:0] baud_cnt;
wire [2:0] bit_cnt;
wire [7:0] data_reg;
receiver #(
    .clk_freq(100),
    .baud_rate(10)
)
dut (
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .data_out(data_out),
    .rx_done(rx_done),
    .state(state),
    .baud_cnt(baud_cnt),
    .bit_cnt(bit_cnt),
    .data_reg(data_reg)
);

always #5 clk = ~clk;

initial begin
    #20 rst = 0;
    rx = 0; #100;   // start bit
    rx = 0; #100;   
    rx = 1; #100;   
    rx = 0; #100;   
    rx = 1; #100;   
    rx = 0; #100;   
    rx = 0; #100;   
    rx = 1; #100;   
    rx = 1; #100;   
    rx = 1; #100;   // stop bit
    #100
    $finish;
end
endmodule

