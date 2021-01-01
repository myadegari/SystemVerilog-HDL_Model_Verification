/*
 The CHTL module is used to Sniffing the generator output applied to the DUV to access the commands.
 Finally, by buffering the information in the output packet,
 it is sent for use in other sections and the golden model.
 and store input cammand times in the file. 
 *****************************************************************************
 The output packet contains the command, tag, data of the first and second operands.

*/
module CHTL (port,paket_out,req_cmd_in,req_data_in,req_tag_in,clk,reset);

  input clk,reset;
  input [31:0] req_data_in;
  input [3:0] req_cmd_in;
  input [1:0] req_tag_in;
  input reg [7:0] port;

  output reg [69:0] paket_out;
  time cmd_timestamp_t;

  reg [69:0] temp;
  reg [69:0] temp_t;
  reg [31:0] hold_data1_t,hold_data2_t;
  reg [3:0] hold_cmd,buffer_hold_cmd;
  reg [1:0] hold_tag,buffer_hold_tag;

  int file_id;

  // Save command and tag data
  initial
  begin
    forever
    begin
      hold_cmd <=(reset) ? 4'b0 : req_cmd_in;
      buffer_hold_cmd <= (reset) ? 4'b0 : hold_cmd;
      hold_tag <= (reset) ? 2'b0 : req_tag_in;
      buffer_hold_tag <= (reset) ? 2'b0 : hold_tag;
      @(posedge clk);
    end
  end

  //  Make Timestamp file
  string path_file ="Timelog_Px.txt";

  initial begin
    path_file.putc(9,port);
    file_id =$fopen(path_file,"a+");
     $fwrite(file_id,"------------------------ Timelog Port%s ------------------------\n",port);
    forever begin
      if(req_cmd_in !==4'b0)begin
        if(req_cmd_in!==4'hx)begin
      cmd_timestamp_t = $time;
      $fwrite(file_id,"%0dns\tcmd::%0h tag::%0h\n",cmd_timestamp_t,req_cmd_in,req_tag_in);
        end
      end
      @(req_cmd_in);
    end
    $fclose(file_id);
  end

  // Save the data of the first and second operands
  initial
  begin
    forever
    begin
      hold_data1_t <=
                   (reset) ? 32'b0 :
                   (req_cmd_in != 4'b0) ? req_data_in :
                   hold_data1_t;
      hold_data2_t <=
                   (reset) ? 32'b0 :
                   (hold_cmd != 4'b0) ? req_data_in:
                   hold_data2_t;
      @(posedge clk);
    end
  end

  initial
  begin
    forever
    begin
      // Make temperal Out_Paket
      assign temp_t = {buffer_hold_tag,buffer_hold_cmd,hold_data1_t,hold_data2_t};

      if(reset)
        temp = 0;
      else if(buffer_hold_cmd == 0)
        temp = 0;
      else
        temp = temp_t;

      @(buffer_hold_cmd);
    end
  end

  initial
  begin
    assign paket_out = temp;
  end

endmodule
