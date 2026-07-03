`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/28/2026 07:29:19 PM
// Design Name: 
// Module Name: tb_transmitter
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


module tb_transmitter();
reg clk = 0, rst = 1, tx_start = 0;
reg [7:0] data_in = 8'hA5;
wire tx, busy;
wire [1:0] state;
wire [13:0] baud_cnt;
wire [2:0] bit_cnt;
wire [7:0] data_reg;

transmitter #(.clk_freq(100), .baud_rate(10))
 dut (
    .clk(clk),
    .rst(rst),
    .tx_start(tx_start),
    .data_in(data_in),
    .tx(tx),
    .busy(busy),
    .state(state),
    .baud_cnt(baud_cnt),
    .bit_cnt(bit_cnt),
    .data_reg(data_reg)
      
);

always #5 clk = ~clk;
initial begin
    #20 rst = 0;
    #10 tx_start = 1;
    #10 tx_start = 0;
    #1200 $finish;
end

endmodule
