module Golden_Model(port,clk,reset,paket_in,result_paket_out);

  input clk,reset;
  input reg [7:0] port;
  input [69:0] paket_in;

  output reg [48:0] result_paket_out;
  reg [31:0] result_paket_out_temp;

  reg [31:0] out_result;
  reg [1:0]  exp_resp;
  reg [1:0]  exp_tag;
  int file_id;
  reg s_flow ;
  


  function int make_result(input [31:0] data1,data2,input[3:0] h_cmd,output int resp,output flow);


    case (h_cmd)

      1 : // Add
      begin
        assign {flow,make_result} = data1 + data2; // To calculate the sum and overflow
        if (flow === 1'b1)
        begin
          assign resp = 2;
          assign make_result = 32'b0;
        end
        else assign resp =1;
      end

      2 : // Subtract
      begin
        if(data1 < data2) // check for Underflow
        begin
          assign make_result =32'b0;
          assign flow = 1;
          assign resp = 2;
        end
        else
        begin
          assign make_result = data1 - data2;
          assign flow = 0;
          assign resp =1;
        end
      end

      6 : // Shift_right
      begin
        assign make_result = data1 >> data2 [4:0];
        assign resp=1;
        assign flow =0;
        end

      5 : // Shift_left
      begin
        assign make_result = data1 << data2 [4:0];
        assign resp=1;
        assign flow=0;
      end

      default: // for invalid commands
      begin
        assign flow = 0;
        assign resp = 2;
        assign make_result = 0;
      end
      
    endcase

  endfunction

  // path_file use for changeable file name

  string path_file ="Golden_result_log_Px.txt";

  initial
  begin
    /*
     change "x" in "Golden_result_log_Px.txt" to Port_number
     Each port has its own Golden model, and the results are stored
     in separate files marked with the number of each port.

     *************************************************************
     putc(19,port) command us for this purpose
     */
    path_file.putc(19,port);
    file_id = $fopen(path_file,"a+");
    $fwrite(file_id,":::::::::::::::::::::::::::::: Golden result Port%s ::::::::::::::::::::::::::::::::::::::::\n",port);

    forever
    begin
      result_paket_out_temp = 0;
      exp_resp = 0;
      s_flow = 0;
      if(paket_in[67:64]==0)begin
        result_paket_out_temp =0;
        exp_resp = 0;
        s_flow = 0;
        exp_tag = 0;
      end
      else begin
      result_paket_out_temp= make_result(paket_in[63:32],paket_in[31:0],paket_in[67:64],exp_resp,s_flow);
      exp_tag = paket_in[69:68];
      end
      /*
        result_paket _out was 49 bit ==>  {8 bit string as port number} + {4 bit as commad}
                                        + {2 bit as tag} + {2 bit respond} + {32 bit result} 
                                        + {1 bit as over/under flow signalca}   
      */

      assign result_paket_out = {port,paket_in[67:64],exp_tag,exp_resp,result_paket_out_temp,s_flow};

      /*
        Printing conditions in txt file: If respond was 0 or cmd was not set,
        which is usually equal to x, nothing is written in the file,
        but if these conditions are not met, there are different conditions for writing in the file,
        a condition for overflow In the addition operation and another 
        for the underflow in the subtraction operation,
        otherwise cmd and tag, port number, first and second data,
        operation result and respond are printed in the file.
      */

      if(exp_resp!==0 & paket_in[67:64]!==4'hx)
      begin
        if(s_flow!==0)
        begin
          if(paket_in[67:64]==4'b0010)
            // subtract Underflow status
            $fwrite(file_id,":: Port%s cmd:%h tag::%h Data1:%h Data2:%h Result:%h Resp::%h :: Underflow ::\n"
                    ,result_paket_out[48:41]  // Port_number
                    ,result_paket_out[40:37]  // Command Type
                    ,result_paket_out[36:35]  // Tag_number
                    ,paket_in[63:32]          // Data_in_1
                    ,paket_in[31:0]           // Data_in_2
                    ,result_paket_out[32:1]   // Result_data
                    ,result_paket_out[34:33]);// Exp_Respond
          else
            // Sum Overflow status
            $fwrite(file_id,":: Port%s cmd:%h tag::%h Data1:%h Data2:%h Result:%h Resp::%h :: Overflow  ::\n"
                    ,result_paket_out[48:41]
                    ,result_paket_out[40:37]
                    ,result_paket_out[36:35]
                    ,paket_in[63:32]
                    ,paket_in[31:0]
                    ,result_paket_out[32:1]
                    ,result_paket_out[34:33]);
        end
        else
          // Normal Status
          $fwrite(file_id,":: Port%s cmd:%h tag::%h Data1:%h Data2:%h Result:%h Resp::%h\n"
                  ,result_paket_out[48:41]
                  ,result_paket_out[40:37]
                  ,result_paket_out[36:35]
                  ,paket_in[63:32]
                  ,paket_in[31:0]
                  ,result_paket_out[32:1]
                  ,result_paket_out[34:33]);
      end
      @(posedge clk);
    end
    $fclose(file_id);

  end

endmodule
