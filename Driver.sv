`include "sv_Interfaces.sv"

class Driver;

  int portNumber;
  virtual Port_Stimuli SPort;
  virtual Port_Global GlobalPort;




  function new (int _portNumber, virtual Port_Global _GlobalPort, virtual Port_Stimuli _SPort);
    begin
      this.SPort     = _SPort;
      this.GlobalPort = _GlobalPort;
    end
  endfunction

  //--------

  // simple Commands:
  // define Add,Sub,SHL(Shift_left),SHR(Shift_right)

  //----------------

  task Add(int Data1,int Data2, int Tag);
    begin
      SPort.req_cmd_in = 4'b0001;
      SPort.req_data_in = Data1;
      SPort.req_tag_in = Tag;
      @(posedge GlobalPort.clk);
      SPort.req_cmd_in = 0;
      SPort.req_data_in = Data2;
      SPort.req_tag_in = 0;
      @(posedge GlobalPort.clk);
      SPort.req_data_in = 0;
    end
  endtask


  task Sub(int Data1,int Data2, int Tag);
    begin
      SPort.req_cmd_in = 4'b0010;
      SPort.req_data_in = Data1;
      SPort.req_tag_in = Tag;
      @(posedge GlobalPort.clk);
      SPort.req_cmd_in = 0;
      SPort.req_data_in = Data2;
      SPort.req_tag_in = 0;
      @(posedge GlobalPort.clk);
      SPort.req_data_in = 0;
    end
  endtask

  task SHL (int Data, int Shift_number, int Tag);
    begin
      SPort.req_cmd_in = 4'b0101;
      SPort.req_data_in = Data;
      SPort.req_tag_in = Tag;
      @(posedge GlobalPort.clk);
      SPort.req_cmd_in = 0;
      SPort.req_data_in = Shift_number;
      SPort.req_tag_in = 0;
      @(posedge GlobalPort.clk);
      SPort.req_data_in = 0;
    end
  endtask

  task SHR (int Data, int Shift_number, int Tag);
    begin
      SPort.req_cmd_in = 4'b0110;
      SPort.req_data_in = Data;
      SPort.req_tag_in = Tag;
      @(posedge GlobalPort.clk);
      SPort.req_cmd_in = 0;
      SPort.req_data_in = Shift_number;
      SPort.req_tag_in = 0;
      @(posedge GlobalPort.clk);
      SPort.req_data_in = 0;
    end
  endtask



endclass //Driver
