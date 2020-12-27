
//`include "holder.v"

module Golden_Model(clk,reset,paket_in,result_paket_out,out_resp);
  
  input clk,reset;
  input [69:0] paket_in;
  output reg [31:0] result_paket_out;
  reg [31:0] result_paket_out_temp;

  reg [31:0] out_result;
  output reg [1:0] out_resp;
  int check = 'hFFFFFFFF;
  reg s_flow ;
  // logic check;
    //  holder H(h_data1,h_data2,h_cmd,h_tag,paket_in,clk,reset);
  function int make_result(input [31:0] data1,data2,input[3:0] h_cmd,output int resp,output flow);//,output int resp,make_result);
    flow =0;
    resp = 1;
    
    case (h_cmd)
      1 :
      begin
        $display("%dns:flow::%b",$time,flow);
        assign {flow,make_result} = data1 + data2;
        if (flow === 1'b1)begin
          resp = 2;
          assign make_result = 32'b0;
        end
      end

      2 :
      begin
        if(data1 < data2)
        begin
          assign make_result =32'b0;
          flow = 1;
          resp = 2;
        end
        else
          make_result = data1 - data2;
      end
      6 :
         make_result = data1 >> data2 [4:0];
      5 :
        make_result = data1 << data2 [4:0];
      default:
      begin
        resp = 2;
        make_result = 0;
      end
    endcase

  endfunction

  initial begin
    forever begin
    //repeat (3) @(posedge clk);
    //check = h_data1 | h_data2 | h_cmd | h_tag ;
    if (paket_in == 0)begin
      result_paket_out = 0;
      out_resp = 0;
    end
    else 
    result_paket_out_temp= make_result(paket_in[63:32],paket_in[31:0],paket_in[67:64],out_resp,s_flow);//,out_resp,out_result);
    // $display("");
    result_paket_out = result_paket_out_temp;
    //assign result_paket_out_temp = out_result;//{out_result,out_resp,h_tag};
    //result_paket_out = result_paket_out_temp;
    @(posedge clk);
    end
    // end
     
  end

endmodule
