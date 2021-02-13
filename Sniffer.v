module Sniffer(clk,data_port1,data_port2,data_port3,data_port4,resp_port1,resp_port2,resp_port3,resp_port4,tag_port1,tag_port2,tag_port3,tag_port4,Paket_port1,Paket_port2,Paket_port3,Paket_port4);
  input clk;
  input [31:0] data_port1;
  input [31:0] data_port2;
  input [31:0] data_port3;
  input [31:0] data_port4;
  input [1:0] resp_port1;
  input [1:0] resp_port2;
  input [1:0] resp_port3;
  input [1:0] resp_port4;
  input [1:0] tag_port1;
  input [1:0] tag_port2;
  input [1:0] tag_port3;
  input [1:0] tag_port4;

  output  [35:0] Paket_port1;
  output  [35:0] Paket_port2;
  output  [35:0] Paket_port3;
  output  [35:0] Paket_port4;

  reg [35:0] temp1;
  reg [35:0] temp2;
  reg [35:0] temp3;
  reg [35:0] temp4;

  always @(*)
  begin
    temp1 <= {tag_port1,resp_port1,data_port1};
    temp2 <= {tag_port2,resp_port2,data_port2};
    temp3 <= {tag_port3,resp_port3,data_port3};
    temp4 <= {tag_port4,resp_port4,data_port4};

  end

  assign Paket_port1 = temp1;
  assign Paket_port2 = temp2;
  assign Paket_port3 = temp3;
  assign Paket_port4 = temp4;



endmodule
