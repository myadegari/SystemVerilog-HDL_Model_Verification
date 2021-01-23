`include "sv_Interfaces.sv"
`include "Generator.sv"
`include "Checker.sv"
`include "DUT/calc2_top.v"
`include "Golden_model.sv"
`include "Sniffer.v"
`include "Scoreboard.sv"



program Top_test(Port_Global GlobalPort, Port_Stimuli SPort1, Port_Stimuli SPort2, Port_Stimuli SPort3,
                   Port_Stimuli SPort4, Port_Score ScoreP1,Port_Score ScoreP2,Port_Score ScoreP3,Port_Score ScoreP4
                   ,Port_Checker CheckP1,Port_Checker CheckP2,Port_Checker CheckP3,Port_Checker CheckP4);

  event  Finish;


  TestGenerator Generator = new(GlobalPort, SPort1, SPort2, SPort3, SPort4, Finish);
  
  Scoreboard Scoreboard_P1 = new("1",ScoreP1,GlobalPort);
  Scoreboard Scoreboard_P2 = new("2",ScoreP2,GlobalPort);
  Scoreboard Scoreboard_P3 = new("3",ScoreP3,GlobalPort);
  Scoreboard Scoreboard_P4 = new("4",ScoreP4,GlobalPort);

  Checker Checker_P1 =new("1",GlobalPort,CheckP1,Scoreboard_P1, Finish);
  Checker Checker_P2 =new("2",GlobalPort,CheckP2,Scoreboard_P2, Finish);
  Checker Checker_P3 =new("3",GlobalPort,CheckP3,Scoreboard_P3, Finish);
  Checker Checker_P4 =new("4",GlobalPort,CheckP4,Scoreboard_P4, Finish);

  initial
  begin
    $write("%dns : Simulation start\n",$time);
    fork
      Generator.Runtest();
      Scoreboard_P1.start();
      Checker_P1.start();
      Scoreboard_P2.start();
      Scoreboard_P3.start();
      Scoreboard_P4.start();
      
      Checker_P2.start();
      Checker_P3.start();
      Checker_P4.start();
    join_any
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
  wire [36:0] Golden_exp_result_1,Golden_exp_result_2,Golden_exp_result_3,Golden_exp_result_4;
  wire [35:0] out_packet_p1,out_packet_p2,out_packet_p3,out_packet_p4;
  /*-------------------------

  --------------------*/

  wire [69:0] Command_packet1,Command_packet2,Command_packet3,Command_packet4;
  // wire flag_p1,flag_p2,flag_p3,flag_p4;
  /*
  ----------------------------------------------------------------
  Define and linked the variables constructed above to the characteristics defined in sv_Interfaces.sv
  ----------------------------------------------------------------
  */

  Port_Global GlobalPort(clk,reset);
  Port_Stimuli SPort1(req1_cmd_in,req1_tag_in,req1_data_in,Command_packet1);
  Port_Stimuli SPort2(req2_cmd_in,req2_tag_in,req2_data_in,Command_packet2);
  Port_Stimuli SPort3(req3_cmd_in,req3_tag_in,req3_data_in,Command_packet3);
  Port_Stimuli SPort4(req4_cmd_in,req4_tag_in,req4_data_in,Command_packet4);

  Port_Score ScoreP1(Command_packet1,Golden_exp_result_1);
  Port_Score ScoreP2(Command_packet2,Golden_exp_result_2);
  Port_Score ScoreP3(Command_packet3,Golden_exp_result_3);
  Port_Score ScoreP4(Command_packet4,Golden_exp_result_4);
  
  Port_Checker CheckP1(out_packet_p1);
  Port_Checker CheckP2(out_packet_p2);
  Port_Checker CheckP3(out_packet_p3);
  Port_Checker CheckP4(out_packet_p4);
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
             .SPort4(SPort4),
             .ScoreP1(ScoreP1),
             .ScoreP2(ScoreP2),
             .ScoreP3(ScoreP3),
             .ScoreP4(ScoreP4),
             .CheckP1(CheckP1),
             .CheckP2(CheckP2),
             .CheckP3(CheckP3),
             .CheckP4(CheckP4)
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

      
  Sniffer Sniffer (clk,out_data1,out_data2,out_data3,out_data4
                ,out_resp1,out_resp2,out_resp3,out_resp4
                ,out_tag1,out_tag2,out_tag3,out_tag4
                ,out_packet_p1,out_packet_p2,out_packet_p3,out_packet_p4);

  //*******************
  

  // CHTL H1("1",Command_packet1,req1_cmd_in,req1_data_in,req1_tag_in,flag_p1,clk,reset);
  Golden_Model gold1 ("1",Command_packet1,Golden_exp_result_1);
  // CHTL H2("2",Command_packet2,req2_cmd_in,req2_data_in,req2_tag_in,flag_p2,clk,reset);
  Golden_Model gold2 ("2",Command_packet2,Golden_exp_result_2);
  // CHTL H3("3",Command_packet3,req3_cmd_in,req3_data_in,req3_tag_in,flag_p3,clk,reset);
  Golden_Model gold3 ("3",Command_packet3,Golden_exp_result_3);
  // CHTL H4("4",Command_packet4,req4_cmd_in,req4_data_in,req4_tag_in,flag_p4,clk,reset);
  Golden_Model gold4 ("4",Command_packet4,Golden_exp_result_4);
  
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
