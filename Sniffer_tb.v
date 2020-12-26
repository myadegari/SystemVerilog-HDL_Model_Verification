`include "Sniffer.v"

module Sniffer_tb;
reg clk;
reg [31:0] data_port1;
reg [31:0] data_port2;
reg [31:0] data_port3;
reg [31:0] data_port4;
reg [3:0] cmd_port1;
reg [3:0] cmd_port2;
reg [3:0] cmd_port3;
reg [3:0] cmd_port4;
reg [1:0] tag_port1;
reg [1:0] tag_port2;
reg [1:0] tag_port3;
reg [1:0] tag_port4;

wire  [37:0] Paket_port1;
wire  [37:0] Paket_port2;
wire  [37:0] Paket_port3;
wire  [37:0] Paket_port4;

sniffer Snif(.clk (clk),
             .data_port1(data_port1),
             .data_port2(data_port2),
             .data_port3(data_port3),
             .data_port4(data_port4),
             .cmd_port1(cmd_port1),
             .cmd_port2(cmd_port2),
             .cmd_port3(cmd_port3),
             .cmd_port4(cmd_port4),
             .tag_port1(tag_port1),
             .tag_port2(tag_port2),
             .tag_port3(tag_port3),
             .tag_port4(tag_port4),
             .Paket_port1(Paket_port1),
             .Paket_port2(Paket_port2),
             .Paket_port3(Paket_port3),
             .Paket_port4(Paket_port4));


initial begin
    clk = 0;
    cmd_port1 = 0;
    cmd_port2 = 0;
    cmd_port3 = 0;
    cmd_port4 = 0;

    data_port1 = 0;
    data_port2 = 0;
    data_port3 = 0;
    data_port4 = 0;

    tag_port1 = 0;
    tag_port2 = 0;
    tag_port3 = 0;
    tag_port4 = 0;

end
always #100 clk = ~clk;

initial begin
    #200
    cmd_port1 = 1;
    cmd_port2 = 2;
    cmd_port3 = 4'b0110;
    cmd_port4 = 4'b0101;

    data_port1 = 25;
    data_port2 = 25;
    data_port3 = 25;
    data_port4 = 25;

    tag_port1 = 0;
    tag_port2 = 2;
    tag_port3 = 3;
    tag_port4 = 1;

end

endmodule