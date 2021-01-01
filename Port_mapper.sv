`include "sv_Interfaces.sv"
`include "Generator.sv"
`include "DUT/calc2_top.v"
`include "Golden_model.sv"
`include "Command_holder_and_time_logger.SV"



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
  wire [48:0] Golden_exp_result_1,Golden_exp_result_2,Golden_exp_result_3,Golden_exp_result_4;

  /*-------------------------

  --------------------*/

  wire [69:0] Command_paket1,Command_paket2,Command_paket3,Command_paket4;
  // wire [1:0] Golden_exp_resp1,Golden_exp_resp2,Golden_exp_resp3,Golden_exp_resp4;
  // wire s_flow1,s_flow2,s_flow3,s_flow4;
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


  //*******************
  

  CHTL H1("1",Command_paket1,req1_cmd_in,req1_data_in,req1_tag_in,clk,reset);
  Golden_Model gold1 ("1",clk,reset,Command_paket1,Golden_exp_result_1);
  CHTL H2("2",Command_paket2,req2_cmd_in,req2_data_in,req2_tag_in,clk,reset);
  Golden_Model gold2 ("2",clk,reset,Command_paket2,Golden_exp_result_2);
  CHTL H3("3",Command_paket3,req3_cmd_in,req3_data_in,req3_tag_in,clk,reset);
  Golden_Model gold3 ("3",clk,reset,Command_paket3,Golden_exp_result_3);
  CHTL H4("4",Command_paket4,req4_cmd_in,req4_data_in,req4_tag_in,clk,reset);
  Golden_Model gold4 ("4",clk,reset,Command_paket4,Golden_exp_result_4);
  
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
