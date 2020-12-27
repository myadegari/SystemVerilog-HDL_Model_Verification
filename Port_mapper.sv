`include "sv_Interfaces.sv"
`include "Generator.sv"
`include "DUT/calc2_top.v"
`include "Sniffer.v"
`include "Golden_model.sv"



program Top_test(Port_Global GlobalPort, Port_Stimuli SPort1, Port_Stimuli SPort2, Port_Stimuli SPort3,
                   Port_Stimuli SPort4);

  event       Finish;


  TestGenerator Generator = new(GlobalPort, SPort1, SPort2, SPort3, SPort4, Finish);


  initial
  begin
    $write("%dns : Simulation start\n",$time);
    fork
      Generator.Runtest();
    join
    $write("%dns : Simulation finished\n",$time);
  end
endprogram


module Simulate_this_for_Run_tests;



  reg 	 clk,a_clk, b_clk, scan_in;
  reg [0:3] 	 req1_cmd_in, req2_cmd_in, req3_cmd_in, req4_cmd_in;
  reg [0:1] 	 req1_tag_in, req2_tag_in, req3_tag_in, req4_tag_in;
  reg [0:31]  req1_data_in, req2_data_in, req3_data_in, req4_data_in;
  wire 	 scan_out;
  wire [31:0] out_data1,out_data2,out_data3,out_data4;
  wire [1:0] out_resp1,out_resp2,out_resp3,out_resp4,out_tag1,out_tag2,out_tag3,out_tag4;
  wire [37:0] p1,p2,p3,p4;
  wire [31:0] rp1,rp2,rp3,rp4;

  /*-------------------------
  --------------------*/
  wire [31:0] h_data1,h_data2;
  wire [3:0] h_cmd;
  wire [1:0] h_tag;
  wire [69:0] temp;
  wire [1:0] out_resp;
  /*
  ----------------------------------------------------------------
  Define and linked the variables constructed above to the characteristics defined in sv_Interfaces.sv
  ----------------------------------------------------------------
  */
  Port_Global GlobalPort(clk,reset);
  Port_Stimuli SPort1(req1_cmd_in,req1_tag_in,req1_data_in);
  Port_Stimuli SPort2(req2_cmd_in,req2_tag_in,req2_data_in);
  Port_Stimuli SPort3(req3_cmd_in,req3_tag_in,req3_data_in);
  Port_Stimuli SPort4(req4_cmd_in,req4_tag_in,req4_data_in);

  /*
  -------------------------------------------------------------------
  connected Top_Test Program to instant of interfaces that makes above
  ------------------------------------------------------------------
  */
  Top_test Main(
             .GlobalPort(GlobalPort),
             .SPort1(SPort1),
             .SPort2(SPort2),
             .SPort3(SPort3),
             .SPort4(SPort4)
           );

  /*
  -------------------------------------------------------------------------
  connected DUT module to Generator wires and Global.Clock and Global.reset and prepared to Drive Test Cases
  -------------------------------------------------------------------------
  */
  calc2_top C2 (
              .a_clk(a_clk),
              .b_clk(b_clk),
              .c_clk(clk),
              .reset(reset),
              .scan_in(scan_in),
              .req1_cmd_in(req1_cmd_in),
              .req1_data_in(req1_data_in),
              .req1_tag_in(req1_tag_in),
              .req2_cmd_in(req2_cmd_in),
              .req2_data_in(req2_data_in),
              .req2_tag_in(req2_tag_in),
              .req3_cmd_in(req3_cmd_in),
              .req3_data_in(req3_data_in),
              .req3_tag_in(req3_tag_in),
              .req4_cmd_in(req4_cmd_in),
              .req4_data_in(req4_data_in),
              .req4_tag_in(req4_tag_in),
              .out_tag1(out_tag1),
              .out_tag2(out_tag2),
              .out_tag3(out_tag3),
              .out_tag4(out_tag4),
              .out_resp1(out_resp1),
              .out_resp2(out_resp2),
              .out_resp3(out_resp3),
              .out_resp4(out_resp4),
              .out_data1(out_data1),
              .out_data2(out_data2),
              .out_data3(out_data3),
              .out_data4(out_data4),
              .scan_out(scan_out)
            );

  Sniffer paket_maker(clk,req1_data_in,req2_data_in,req3_data_in,
                     req4_data_in,req1_cmd_in,req2_cmd_in,req3_cmd_in,
                     req4_cmd_in,req1_tag_in,req2_tag_in,req3_tag_in,
                     req4_tag_in,p1,p2,p3,p4);

  //*******************
  holder H(temp,p1,clk,reset);
  Golden_Model gold1 (clk,reset,temp,rp1,out_resp);
  // Golden_Model gold2 (clk,reset,p2,rp2);
  // Golden_Model gold3 (clk,reset,p3,rp3);
  // Golden_Model gold4 (clk,reset,p4,rp4);
  //****************

  /*
  -----------------------------------------------------------------
      initialize input control signals and build a Clock signal
  -----------------------------------------------------------------
  */

  initial
  begin
    clk = 0;
    a_clk = 0;
    b_clk = 0;
    scan_in = 0;
  end

  initial
    forever
      #100 clk ++;
    endmodule
