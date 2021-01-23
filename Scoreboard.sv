`include "sv_Interfaces.sv"
`ifndef SCOREBOARD
`define SCOREBOARD

        class Scoreboard;

          reg[7:0] Port_number;
          virtual Port_Score ScorePort;
          virtual Port_Global GlobalPort;

          function new (reg[7:0] _Port_number,virtual Port_Score _ScorePort, virtual Port_Global _GlobalPort);
            begin
              this.ScorePort = _ScorePort;
              this.GlobalPort = _GlobalPort;
              this.Port_number = _Port_number;
            end
          endfunction

          //The queues used in the scoreboard are as follows
          bit [69:0] queue_of_input_commands   [$];
          bit [36:0] queue_of_expected_results [$];
          bit [1 :0] queue_of_input_tags       [$];

          task start();
            fork
              save_commands();
              save_expected_results();
            join
          endtask

          task save_commands();
            bit reset_detection_flag;
            reg [69:0] cmd_holder;
            reg [1 :0] tag_holder;

            forever
            begin

              cmd_holder = ScorePort.CMD_packet_in[69:0];
              tag_holder = ScorePort.CMD_packet_in[69:68];

              // Make sure Queue is empty
              if(GlobalPort.reset)
              begin
                if(queue_of_input_tags.size()!==0)begin
                  reset_detection_flag=1;
                  while(reset_detection_flag)
                  begin
                    if(queue_of_input_tags.size()==0)begin
                    reset_detection_flag=0;
                    cmd_holder='0;
                    end
                    else begin
                   tag_holder=queue_of_input_tags.pop_front();
                  cmd_holder=queue_of_input_commands.pop_front();
                    end
                  end
                end
                else
                  cmd_holder='0;
              end

              if(cmd_holder!=0)
              begin
                queue_of_input_commands.push_back(cmd_holder);
                queue_of_input_tags.push_back(tag_holder);
              end
              @(ScorePort.CMD_packet_in);
            end
          endtask

          task save_expected_results();
            bit reset_detection_flag;
            reg [36:0] holds_the_expected_results;
            reg [1:0] expected_tag;
            reg [1:0] expected_response;

            forever
            begin

              expected_response          = ScorePort.EXP_packet_in[34:33];
              expected_tag               = ScorePort.EXP_packet_in[36:35];
              holds_the_expected_results = ScorePort.EXP_packet_in[36:0];

              // Make sure Queue is empty
              if(GlobalPort.reset)
              begin
                if(queue_of_expected_results.size()!==0)begin
                  reset_detection_flag=1;
                  while(reset_detection_flag)
                  begin
                    if(queue_of_expected_results.size()==0)begin
                    reset_detection_flag=0;
                    expected_response='0;
                    end
                    else
                    holds_the_expected_results=queue_of_expected_results.pop_front();
                  end
                end
                else
                  expected_response='0;
              end

              if(expected_response!==0 )
                if(expected_tag !==2'bxx)
                  queue_of_expected_results.push_back(holds_the_expected_results);

              @(ScorePort.EXP_packet_in);
            end
          endtask


          task get(input [1:0] tag_received_from_checker,output bit [69:0] submission_command,output bit [36:0] submission_expected_result,output bit result_type_detection_flag);
            begin
              int received_tag_index [$];
              int empty_queue_for_comparison_criteria [$];
              bit [36:0] fetch_expected_result;
              bit [69:0] fetch_command;
              bit stray_data_detection_flag;

              /*
              Using the tag received from the checker,
              it searches the tag queues and, if any,
              according to the index found in the search in
              the CMD queues and the expected results,
              and fetches the data from these queues to The checker is sent for review.
              */

              received_tag_index = queue_of_input_tags.find_first_index(x) with (x == tag_received_from_checker);


              if(received_tag_index != empty_queue_for_comparison_criteria)
              begin

                {>>{fetch_command}} = queue_of_input_commands [received_tag_index[0]];
                {>>{fetch_expected_result}} = queue_of_expected_results [received_tag_index[0]];

                /*
                If the first and second cells of the tag queue are the same,
                it is due to the existence of duplicate tags in the commands
                and the data received from the golden model must be corrected.
                */
                if(queue_of_input_tags[0]==queue_of_input_tags[1])
                begin

                  queue_of_expected_results[1]={fetch_command[69:68],2'b10,33'b0};
                end

                stray_data_detection_flag=0;

                queue_of_input_tags.delete(received_tag_index[0]);
                queue_of_expected_results.delete(received_tag_index[0]);
                queue_of_input_commands.delete(received_tag_index[0]);

                result_type_detection_flag = stray_data_detection_flag;
                submission_command = fetch_command;
                submission_expected_result = fetch_expected_result;

              end
              else
              begin

                submission_command =7;
                submission_expected_result = 0;
                result_type_detection_flag = 1;

              end
            end
          endtask
        endclass

`endif
