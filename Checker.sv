`include "Scoreboard.sv"

class Checker;
  virtual Port_Global GlobalPort;
  virtual Port_Checker CheckP;
  Scoreboard ScoreboardPx;

  reg [7:0] PORT_NUMBER;

  function new(reg [7:0] _PORT_NUMBER,virtual Port_Global _GlobalPort,virtual Port_Checker _CheckP,Scoreboard _ScoreboardPx, event _Finish);
    begin
      this.PORT_NUMBER = _PORT_NUMBER;
      this.GlobalPort = _GlobalPort;
      this.CheckP = _CheckP;
      this.ScoreboardPx = _ScoreboardPx;

    end
  endfunction

  task start();
    int FILE_ID;
    string FILE_PATH = "Check_Px.txt";
    int data_received_counter =0;
    FILE_PATH.putc(7,PORT_NUMBER);
    FILE_ID = $fopen(FILE_PATH,"a+");
    $fwrite(FILE_ID,"::::::::::::Check_Port%s::::::::::::\n\n",PORT_NUMBER);
    forever
    begin
      reg result_type_detection_flag;
      reg [69:0] issued_command;
      reg [36:0] golden_model_result;
      reg [35:0] duv_result;
      string cmd_name;
      duv_result = CheckP.duv_out;

      if(duv_result != 0 )
      begin
        data_received_counter++;

        result_type_detection_flag=1;

        if(duv_result[33:32]!=0)
        ScoreboardPx.get(duv_result[35:34],issued_command,golden_model_result,result_type_detection_flag); //Get data from Scoreboard

        case(issued_command[67:64]) // find cmd name
          4'b0001: cmd_name ="ADD";
          4'b0010: cmd_name ="SUB";
          4'b0110: cmd_name ="SHR";
          4'b0101: cmd_name ="SHL";
          default: cmd_name ="INV";
        endcase

        if(result_type_detection_flag==0)
        begin
          if(golden_model_result[36:1] == duv_result)begin
            $fwrite(FILE_ID,"::%0dns:C-%0d: Pass\n",$time,data_received_counter);
          end
          else
          begin
            if (golden_model_result[34:33]!= duv_result[33:32])
              $fwrite(FILE_ID,"::%0dns:%s-%0d: !Fault! { Wrong-Response } Actual:%h Expected:%h\n",$time,cmd_name,data_received_counter,duv_result[33:32],golden_model_result[34:33]);
            if (golden_model_result[32:1]!= duv_result[31:0])
              $fwrite(FILE_ID,"::%0dns:%s-%0d: !Fault! { Wrong-Result } Operand1:%h Operand2:%h Actual:%h Expected:%h\n",$time,cmd_name,data_received_counter,issued_command[63:32],issued_command[31:0],duv_result[31:0],golden_model_result[32:1]);
          end
        end
        else begin
          if(duv_result[33:32]!=0)
            $fwrite(FILE_ID,"::%0dns:C-%0d: !Fault! {  Stray Response  }\n",$time,data_received_counter);
          if(duv_result[35:34]!=0)
            $fwrite(FILE_ID,"::%0dns:C-%0d: !Fault! {  Stray Tag  }\n",$time,data_received_counter);
        end
      end
      @(negedge GlobalPort.clk);
    end
    
    // $fclose(FILE_ID);
  endtask

endclass
