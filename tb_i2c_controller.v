`timescale 1ns / 1ps

module tb_i2c_controller;

reg clk;
reg rst;
reg [6:0] addr;
reg [7:0] wdata;
reg enable;
reg rw;

wire [7:0] data_out;
wire ready;
wire i2c_sda;
wire i2c_scl;

// Instantiate DUT
i2c_controller uut (
    .clk(clk),
    .rst(rst),
    .addr(addr),
    .wdata(wdata),
    .enable(enable),
    .rw(rw),
    .data_out(data_out),
    .ready(ready),
    .i2c_sda(i2c_sda),
    .i2c_scl(i2c_scl)
);

// Clock generation
always #5 clk = ~clk;

// Initial block
initial begin
    $dumpfile("i2c.vcd");
    $dumpvars(0, tb_i2c_controller);

    clk = 0;
    rst = 1;
    addr = 7'b1010101;
    wdata = 8'hA5;
    enable = 0;
    rw = 0; // Write

    #20;
    rst = 0;
    #20;
    enable = 1;

    // Hold enable for some cycles
    #50;
    enable = 0;

    // Wait for transaction to finish
    #1000;
    $finish;
end

endmodule
