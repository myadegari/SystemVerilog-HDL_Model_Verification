module Golden_Model(PORT_NUMBER,packet_imported,output_packet_result);

  input reg [7:0] PORT_NUMBER;
  input [69:0] packet_imported;

  output reg [36:0] output_packet_result;
  
  reg [31:0]  temporary_result;
  reg [1 :0]  expected_response;
  reg [1 :0]  expected_tag;
  reg         recognition_bit ;
  int FILE_ID;
 
  


  function int make_result(input [31:0] data_a,data_b,input[3:0] received_commands,output int respond,output recognition_bit);
    
    bit [31:0] shift_overflow_check;

    case (received_commands)

      1 : // Add
      begin
        assign {recognition_bit,make_result} = data_a + data_b; // To calculate the sum and overflow
        if (recognition_bit!=0)
        begin
          assign respond     = 2;
          assign make_result = 32'b0;
        end
        else assign respond  =1;
      end

      2 : // Subtract
      begin
        if(data_a < data_b) // check for Underflow
        begin
          assign make_result     = 32'b0;
          assign recognition_bit = 1;
          assign respond         = 2;
        end
        else
        begin
          assign make_result     = data_a - data_b;
          assign recognition_bit = 0;
          assign respond         = 1;
        end
      end

      6 : // Shift_right
      begin
        assign make_result     = data_a >> data_b [4:0];
        assign respond         = 1;
        assign recognition_bit = 0;
        end

      5 : // Shift_left
      begin
        assign make_result     = data_a << data_b [4:0];
        assign respond         = 1;
        assign recognition_bit = 0;
      end

      default: // for invalid commands
      begin
        assign recognition_bit = 0;
        assign respond         = 2;
        assign make_result     = 32'b0;
      end
      
    endcase

  endfunction

  // FILEPATH use for changeable file name

  string FILE_PATH ="Golden_result_log_Px.txt";

  initial
  begin
    /*
     change "x" in "Golden_result_log_Px.txt" to Port_number
     Each PORT_NUMBER has its own Golden model, and the results are stored
     in separate files marked with the number of each PORT_NUMBER.

     *************************************************************
     putc(19,PORT_NUMBER) command us for this purpose
     */
    FILE_PATH.putc(19,PORT_NUMBER);
    FILE_ID = $fopen(FILE_PATH,"w");
    $fwrite(FILE_ID,":::::::::::::::::::::::::::::: Golden result Port%s ::::::::::::::::::::::::::::::::::::::::\n",PORT_NUMBER);

    forever
    begin

      temporary_result      = 0;
      expected_response     = 0;
      recognition_bit       = 0;

      if(packet_imported[67:64]==0)begin
        
        temporary_result      = 0;
        expected_response     = 0;
        recognition_bit       = 0;
        expected_tag          = 0;

      end
      else begin
      temporary_result= make_result(packet_imported[63:32],packet_imported[31:0],packet_imported[67:64],expected_response,recognition_bit);
      expected_tag = packet_imported[69:68];
      end

    // output_packet_result was 38 bit ==>{1 bit flag }+ {2 bit as tag} + {2 bit respond} + {32 bit result} + {1 bit as over/underflow signal}   
     
      assign output_packet_result = {expected_tag,expected_response,temporary_result,recognition_bit};
      
      /*
        Printing conditions in txt file: If respond was 0 or cmd was not set,
        which is usually equal to x, nothing is written in the file,
        but if these conditions are not met, there are different conditions for writing in the file,
        a condition for overflow In the addition operation and another 
        for the underflow in the subtraction operation,
        otherwise cmd and tag, PORT_NUMBER number, first and second data,
        operation result and respond are printed in the file.
      */

      if(expected_response!==0 & packet_imported[67:64]!==4'hx)
      begin
        if(recognition_bit!==0)
        begin
          if(packet_imported[67:64]==4'b0010)
            // subtract Underflow status
            $fwrite(FILE_ID,":: Port%s cmd:%h tag::%h Data1:%h Data2:%h Result:%h Resp::%h :: Underflow ::\n"
                    ,PORT_NUMBER                     // Port_number
                    ,packet_imported[67:64]          // Command Type
                    ,output_packet_result[36:35]     // Tag_number
                    ,packet_imported[63:32]          // Data_in_1
                    ,packet_imported[31:0]           // Data_in_2
                    ,output_packet_result[32:1]      // Result_data
                    ,output_packet_result[34:33]);   // Exp_Respond
          else
            // Sum/Shift Overflow status
            $fwrite(FILE_ID,":: Port%s cmd:%h tag::%h Data1:%h Data2:%h Result:%h Resp::%h :: Overflow  ::\n"
                    ,PORT_NUMBER
                    ,packet_imported[67:64]
                    ,output_packet_result[36:35]
                    ,packet_imported[63:32]
                    ,packet_imported[31:0]
                    ,output_packet_result[32:1]
                    ,output_packet_result[34:33]);
                    
        end
        else
          // Normal Status
          $fwrite(FILE_ID,":: Port%s cmd:%h tag::%h Data1:%h Data2:%h Result:%h Resp::%h\n"
                  ,PORT_NUMBER
                  ,packet_imported[67:64]
                  ,output_packet_result[36:35]
                  ,packet_imported[63:32]
                  ,packet_imported[31:0]
                  ,output_packet_result[32:1]
                  ,output_packet_result[34:33]);
      end
      @(packet_imported);
    end
    // $fclose(FILE_ID);

  end

endmodule
