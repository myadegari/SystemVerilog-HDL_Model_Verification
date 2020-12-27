module holder (temp_out,paket_in,clk,reset);
  input clk,reset;
  input [37:0] paket_in;

  output [69:0] temp_out;

  reg [69:0] temp;
  reg [69:0] temp_t;
  reg [31:0] hold_data1_t,hold_data2_t;

  reg [3:0] hold_cmd,buffer_hold_cmd;
  reg [1:0] hold_tag,buffer_hold_tag;

  always @(posedge clk)
  begin
    hold_cmd <=(reset) ? 4'b0 : paket_in[5 : 2];
    buffer_hold_cmd <= (reset) ? 4'b0 : hold_cmd;
    hold_tag <= (reset) ? 2'b0 : paket_in [1 : 0];
    buffer_hold_tag <= (reset) ? 2'b0 : hold_tag;
  end
  always @(posedge clk)
  begin

    hold_data1_t <=
                 (reset) ? 32'b0 :
                 (paket_in[5 : 2] != 4'b0) ? paket_in[37 : 6] :
                 hold_data1_t;
    hold_data2_t <=
                 (reset) ? 32'b0 :
                 (hold_cmd != 4'b0) ? paket_in[37 : 6]:
                 hold_data2_t;
  end

  always @(buffer_hold_cmd)
  begin
   assign temp_t = {buffer_hold_tag,buffer_hold_cmd,hold_data1_t,hold_data2_t};

    if(reset)
      temp = 0;
    else if(buffer_hold_cmd == 0)
      temp = 0;
    else
      temp = temp_t;
  end
  assign temp_out = temp;

endmodule