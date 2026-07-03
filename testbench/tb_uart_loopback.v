`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2026 05:18:06 PM
// Design Name: 
// Module Name: tb_uart_loopback
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


module tb_uart_loopback();
    reg clk = 0;
    reg start = 0;
    reg rst;
    reg [7:0] tx_data=0;
    wire [7:0] rx_data;
    wire rx_done;
    
    uart_loopback  #(
    .clk_freq(100),
    .baud_rate(10)
    ) dut( 
    .clk(clk),
    .start(start),
    .rst(rst),
    .tx_data(tx_data),
    .rx_data(rx_data),
    .rx_done(rx_done)
    );
    always #5 clk = ~clk;
    initial begin
    rst = 1;  //reset
    #20;
    rst = 0;   //release reset
    
    tx_data = 8'h55;   //feeding data
    
    start = 1;     //start bit
    #10;
    start = 0;          // checks rx_data
    #1500;
    if(rx_data == 8'h55)
        $display("PASS");
    else
        $display("FAIL");
    $finish;

  end
endmodule
