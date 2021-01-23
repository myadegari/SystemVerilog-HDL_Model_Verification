`ifndef SV_INTERFACES
`define SV_INTERFACES

interface Port_Stimuli(
    
    output reg [0:3]  req_cmd_in,
    output reg [0:1]  req_tag_in,
    output reg [0:31] req_data_in,
    output reg [69:0] stimuli_out
);
endinterface //Port_Stimuli

interface Port_Global(
    input  reg  clk,
    output reg  reset
    );
endinterface //Port_Global

interface Port_Score(
    input reg [69:0] CMD_packet_in,
    input reg [36:0] EXP_packet_in
);
    
endinterface //Port_Score

interface Port_Checker(
    input [35:0] duv_out
);
    
endinterface //Port_Checker
/*
interface Port_Monitor(
    input reg clk,
    input reg [0:3]  req_cmd_in,
    input reg [0:1]  req_tag_in,
    input reg [0:31] req_data_in,

    input wire [0:31] out_data,
    input wire [0:1]  out_resp,
    input wire [0:1]  out_tag
    );
endinterface //Port_Monitor

*/



`endif