`include "sv_Interfaces.sv"
`include "Driver.sv"
`include "Make_Random.sv"

class TestGenerator;

  virtual Port_Global GlobalPort;

  virtual Port_Stimuli SPort1;
  virtual Port_Stimuli SPort2;
  virtual Port_Stimuli SPort3;
  virtual Port_Stimuli SPort4;

  Driver DrivePort1;
  Driver DrivePort2;
  Driver DrivePort3;
  Driver DrivePort4;

  make_random RandP1;
  make_random RandP2;
  make_random RandP3;
  make_random RandP4;
  make_random RandGlobal;

  event Finish;

  function new(virtual Port_Global _GlobalPort, virtual Port_Stimuli _SPort1, virtual Port_Stimuli _SPort2,
                 virtual Port_Stimuli _SPort3, virtual Port_Stimuli _SPort4, event _Finish);
    begin
      this.GlobalPort = _GlobalPort;
      this.SPort1   = _SPort1;
      this.SPort2   = _SPort2;
      this.SPort3   = _SPort3;
      this.SPort4   = _SPort4;
      this.Finish   = _Finish;

      DrivePort1 = new(1,GlobalPort,SPort1);
      DrivePort2 = new(2,GlobalPort,SPort2);
      DrivePort3 = new(3,GlobalPort,SPort3);
      DrivePort4 = new(4,GlobalPort,SPort4);

      RandP1 = new(1,GlobalPort,SPort1);
      RandP2 = new(2,GlobalPort,SPort2);
      RandP3 = new(3,GlobalPort,SPort3);
      RandP4 = new(4,GlobalPort,SPort4);
      RandGlobal = new(4,GlobalPort,SPort4);


    end
  endfunction

  task Runtest();//Start (including reset) and test all ports with all CMDs and random data_in(s)
    $write("%dns : Generator activated\n",$time);
    full_Test_Selector();
    $write("%dns : Generator finished\n",$time);
  endtask 

  task Simultaneous_Test (int case_sel=4, int make_test=80); // Simultaneous testing of all ports with a common scenarios
    IReset();
    @(posedge GlobalPort.clk);
    GlobalPort.reset     = 0;
    $write("%dns : Simultaneous Test activated\n",$time);
    fork
      testP1(case_sel,make_test);
      testP2(case_sel,make_test);
      testP3(case_sel,make_test);
      testP4(case_sel,make_test);
    join
    repeat(10)@(posedge GlobalPort.clk);
    $write("%dns : Simultaneous Test deactivated\n",$time);

  endtask


  task full_Test_Selector();

    $write("%dns: Start Random Test Selector\n",$time);

    for(int test_count = 1;test_count<5;test_count++)
    begin
      for(int case_count = 0;case_count<7;case_count++)
      begin
        IReset();
        @(posedge GlobalPort.clk);
        GlobalPort.reset = 0;
        case (test_count)
          default:testP1(case_count);
          2:testP2(case_count);
          3:testP3(case_count);
          4:testP4(case_count);
        endcase
      end
    end
    Simultaneous_Test();
    Make_Shift_out_of_order_result ();
    Make_AddSub_out_of_order_result ();
    SimultaneousStaticTest ();
    $write("%dns: End Random Test Selector\n",$time);
    repeat(100)@(posedge GlobalPort.clk);
    -> Finish;

  endtask


  task IReset(int remain = 2);
    begin
      @(posedge GlobalPort.clk);

      SPort1.req_cmd_in  = 0;
      SPort1.req_tag_in  = 0;
      SPort1.req_data_in = 0;
      SPort2.req_cmd_in  = 0;
      SPort2.req_tag_in  = 0;
      SPort2.req_data_in = 0;
      SPort3.req_cmd_in  = 0;
      SPort3.req_tag_in  = 0;
      SPort3.req_data_in = 0;
      SPort4.req_cmd_in  = 0;
      SPort4.req_tag_in  = 0;
      SPort4.req_data_in = 0;
      SPort1.stimuli_out = 0;  // Data output package commands to send to the golden model and the scoreboard
      SPort2.stimuli_out = 0;
      SPort3.stimuli_out = 0;
      SPort4.stimuli_out = 0;

      GlobalPort.reset   = 1;
      $write("%dns : Reset asserted\n",$time);
      repeat(remain)@(posedge GlobalPort.clk);
      $write("%dns : Reset disasserted\n",$time);
    end
  endtask



  task testP1(int testcase_number =4, int make_test=20); // Test Case scenarios for Port1 with default test case number 4
    begin

      case(testcase_number)
        default: // Add and sub Testcases
        begin
          //Test cases for Add
          $write("%dns :Start Checking Add/Sub commands in Port1.\n",$time);

          DrivePort1.Add(50,22,0); // Simple Add test
          DrivePort1.Add(50,0, 1); // One operand is zero
          DrivePort1.Add(22,0, 2); // One operand is zero
          DrivePort1.Add(33,0, 3); // One operand is zero
          DrivePort1.Add(44,0, 0); // One operand is zero
          DrivePort1.Add(45,0, 1); // One operand is zero
          DrivePort1.Add(0,22, 2); // One operand is zero
          DrivePort1.Add(0,23, 3); // One operand is zero
          DrivePort1.Add(0,24, 0); // One operand is zero
          DrivePort1.Add(0,25, 1); // One operand is zero
          DrivePort1.Add(0,26, 2); // One operand is zero
          DrivePort1.Add(0, 0, 3); // two Operands is zero

          repeat(10)@(posedge GlobalPort.clk);

          assert(RandP1.randomize());
          DrivePort1.Add(RandP1.Inputs[0],RandP1.Inputs[1], 0); // make Add result exactly 'hFFFFFFFF
          assert(RandP1.randomize());
          DrivePort1.Add(RandP1.Inputs2[0],RandP1.Inputs2[1], 1); // Make Add overflow by 1
          //-------------------------------------------------------------------------------------------//

          repeat(10)@(posedge GlobalPort.clk);

          DrivePort1.Sub(50,22,2); // Simple Subtract test
          DrivePort1.Sub(50,0, 3); // One Operand is zero
          DrivePort1.Sub(40,0, 0); // One Operand is zero
          DrivePort1.Sub(20,0, 1); // One Operand is zero
          DrivePort1.Sub(10,0, 2); // One Operand is zero
          DrivePort1.Sub(15,0, 3); // One Operand is zero
          DrivePort1.Sub(0,22, 0); // One Operand is zero
          DrivePort1.Sub(0,24, 1); // One Operand is zero
          DrivePort1.Sub(0,25, 2); // One Operand is zero
          DrivePort1.Sub(0,26, 3); // One Operand is zero
          DrivePort1.Sub(0,28, 0); // One Operand is zero
          DrivePort1.Sub(0, 0, 1); // two Operands is zero

          repeat(10)@(posedge GlobalPort.clk);

          DrivePort1.Sub(50,50,2); // Two equal Operands in Sub
          DrivePort1.Sub(50,51,3); // Make Underflow by 1
          //--------------------------------------------------------------------------------------------//

          //----! Make Some Add/Sub commands that sake to Over/UnderFlow  !-----//
          repeat(10)@(posedge GlobalPort.clk);

          DrivePort1.Add('hEFFFFFEF,'h10000011,0);
          DrivePort1.Add('hEFFFFFEE,'h10000012,1);
          DrivePort1.Add('hEFFFFFED,'h10000013,2);
          DrivePort1.Add('hEFFFFFEC,'h10000014,3);
          DrivePort1.Add('hEFFFFFEB,'h10000015,0);
          DrivePort1.Sub(0,1,1);
          DrivePort1.Sub(1,2,2);
          DrivePort1.Sub(2,3,3);
          DrivePort1.Sub(3,4,0);
          DrivePort1.Sub(4,5,1);
          DrivePort1.Add('hFFFFFFFF,3,2);
          DrivePort1.Add('hFFFFFFFF,4,3);
          DrivePort1.Add('hFFFFFFFF,5,0);
          DrivePort1.Add('hFFFFFFFF,6,1);
          DrivePort1.Add('hFFFFFFFF,7,2);
          DrivePort1.Sub('hFFFFFFFC,'hFFFFFFFE,3);
          DrivePort1.Sub('hFFFFFFFb,'hFFFFFFFd,0);
          DrivePort1.Sub('hFFFFFFFa,'hFFFFFFFc,1);
          DrivePort1.Sub('hFFFFFFF9,'hFFFFFFFb,2);
          DrivePort1.Sub('hFFFFFFF8,'hFFFFFFFa,3);


          $write("%dns :End of Checking Add/Sub in Port1.\n",$time);
        end

        1:// Shift Testcases
        begin
          $write("%dns :Start Checking Shift Commands in Port1.\n",$time);

          DrivePort1.SHL('1,'0,0);            // Make Zero Shift Left
          DrivePort1.SHL(56,'0,1);            // Make Zero Shift Left
          DrivePort1.SHL(52,'0,2);            // Make Zero Shift Left
          DrivePort1.SHL(456,'0,3);           // Make Zero Shift Left
          DrivePort1.SHL(1225,'0,0);          // Make Zero Shift Left
          DrivePort1.SHL(1,32,1);             // Make 32 Shift Left
          DrivePort1.SHL(2,32,2);             // Make 32 Shift Left
          DrivePort1.SHL(15,32,3);            // Make 32 Shift Left
          DrivePort1.SHL(32,32,0);            // Make 32 Shift Left
          DrivePort1.SHL(45,32,1);            // Make 32 Shift Left
          DrivePort1.SHR('1,'0,2);            // Make Zero Shift Right
          DrivePort1.SHR(45,'0,3);            // Make Zero Shift Right
          DrivePort1.SHR(12,'0,0);            // Make Zero Shift Right
          DrivePort1.SHR(14,'0,1);            // Make Zero Shift Right
          DrivePort1.SHR(15,'0,2);            // Make Zero Shift Right
          DrivePort1.SHR('h10000000,5'b1,3);  // Make 32 Shift Right
          DrivePort1.SHR(535,5'b1,0);         // Make 32 Shift Right
          DrivePort1.SHR(632,5'b1,1);         // Make 32 Shift Right
          DrivePort1.SHR(425,5'b1,2);         // Make 32 Shift Right
          DrivePort1.SHR(200,5'b1,3);         // Make 32 Shift Right
          DrivePort1.SHL('he11d33e8,'h603a86c1,0);    // 1 bit overflow in left Shift
          DrivePort1.SHL('h097ec66a,'h8b3fed4a,1);    // 6 bit overflow in left Shift
          DrivePort1.SHL('1,'1,2);
          DrivePort1.SHR('1,'1,3);
          repeat(10)@(posedge GlobalPort.clk);

          //--------------------! Check the shift command on the zero operand !---------//

          repeat(2)
          begin
            assert(RandP1.randomize());
            DrivePort1.SHL('0,RandP1.Shift_Operand2,RandP1.tag_maker());
            assert(RandP1.randomize());
            DrivePort1.SHR('0,RandP1.Shift_Operand2,RandP1.tag_maker());
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //-------! Check the shift command on the second operand and the ignored values !--------//

          DrivePort1.SHL('hFFFFFFF0,'hFFFFFFE2, 0);
          DrivePort1.SHL('hFFFFFFF0,'hFEFEFEE1, 1);
          DrivePort1.SHL('hFFFFFFF0,'hFEFEFEE3, 2);
          DrivePort1.SHL('hFFFFFFF0,'hFEFEFEE4, 3);
          DrivePort1.SHL('hFFFFFFF0,'hFEFEFEE5, 0);
          DrivePort1.SHL('hFFFFFFF0,'hFEFEFEE6, 1);
          DrivePort1.SHR('h0FFFFFFF,'hFFFFFFE2, 2);
          DrivePort1.SHR('h0FFFFFFF,'hFEFEFEE1, 3);
          DrivePort1.SHR('h0FFFFFFF,'hFEFEFEE2, 0);
          DrivePort1.SHR('h0FFFFFFF,'hFEFEFEE3, 1);
          DrivePort1.SHR('h0FFFFFFF,'hFEFEFEE4, 2);
          DrivePort1.SHR('h0FFFFFFF,'hFEFEFEE5, 3);

          repeat(10)@(posedge GlobalPort.clk);

          $write("%dns :End of Checking Shift Commands in Port1.\n",$time);
        end

        2:
        begin
          $write("%dns :Start Checking the sequence and prioritize the execution of commands in Port1.\n",$time);
          //--------------! Make 3 Add/Sub and 1 Shift command at the end !-----------------------//
          repeat(3)
          begin
            assert(RandP1.randomize());
            RandP1.do_RandCase(100,50,50,0,0,0,0); // Make 3 Add/Sub command
          end
          assert(RandP1.randomize());
          RandP1.do_RandCase(0,0,0,100,50,50,0);  //Make Shift command
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          // -----------! Make 4 Add/Sub or Shift Commands with random order !--------------------//
          repeat(10)
          begin
            repeat(4)
            begin
              assert(RandP1.randomize());
              RandP1.do_RandCase(50,100,0,50,50,50,0);
            end
            repeat(10)@(posedge GlobalPort.clk);
          end
          $write("%dns :End of Checking the sequence and prioritize the execution of commands in Port1.\n",$time);
        end

        3:
        begin
          $write("%dns :Start Checking Test various schedules and unauthorized commands in Port1.\n",$time);
          //--------------! Make 8 Random Valid Command with Random Time interval !--------------//
          repeat(8)
          begin
            assert(RandP1.randomize());
            RandP1.full_random_valid_command();
            repeat(RandP1.time_delay)@(posedge GlobalPort.clk);
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //---------------! Make 4 Random invalid Command !-----------------------------//

          repeat(4)
          begin
            assert(RandP1.randomize());
            RandP1.full_random_invalid_command();
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //---------------! Send a combination of valid and invalid commands !----------//

          repeat(4)
          begin
            assert(RandP1.randomize());
            RandP1.full_random_valid_command();
            assert(RandP1.randomize());
            RandP1.full_random_invalid_command();
          end
          repeat(10)@(posedge GlobalPort.clk);

          $write("%dns :End of Checking Test various schedules and unauthorized commands in Port1.\n",$time);

        end
        4:
        begin
          $write("%dns :Start sending %0d random valid command in Port1.\n",$time,make_test*4);
          repeat(make_test)
          begin
            repeat(4)
            begin
              assert(RandP1.randomize());
              RandP1.full_random_valid_command();
            end
            assert(RandP1.randomize());
            repeat(RandP1.time_delay)@(posedge GlobalPort.clk);
          end
          $write("%dns :End of sending %0d random valid command in Port1.\n",$time,make_test*4);
        end


        5:
        begin
          $write("%dns :Start Checking Send multiple commands from the same port with the same tags in Port1.\n",$time);

          //-------! Send multiple commands from the same port with the same tags !------//

          repeat(2)
          begin
            assert(RandP1.randomize());
            DrivePort1.SHL(RandP1.Data1,RandP1.Shift_Operand2,0);
            assert(RandP1.randomize());
            DrivePort1.Add(RandP1.Data1,RandP1.Data2,0);
          end

          repeat(10)@(posedge GlobalPort.clk);

          repeat(2)
          begin
            assert(RandP1.randomize());
            DrivePort1.SHR(RandP1.Data1,RandP1.Shift_Operand2,1);
            assert(RandP1.randomize());
            DrivePort1.Add(RandP1.Data1,RandP1.Data2,1);
          end
          repeat(10)@(posedge GlobalPort.clk);

          repeat(2)
          begin
            assert(RandP1.randomize());
            DrivePort1.SHL(RandP1.Data1,RandP1.Shift_Operand2,2);
            assert(RandP1.randomize());
            DrivePort1.Add(RandP1.Data1,RandP1.Data2,2);
          end
          repeat(10)@(posedge GlobalPort.clk);

          repeat(2)
          begin
            assert(RandP1.randomize());
            DrivePort1.SHR(RandP1.Data1,RandP1.Shift_Operand2,3);
            assert(RandP1.randomize());
            DrivePort1.Add(RandP1.Data1,RandP1.Data2,3);
          end
          repeat(10)@(posedge GlobalPort.clk);

          $write("%dns :End of Checking Send multiple commands from the same port with the same tags in Port1.\n",$time);

        end
        6:
        begin
          $write("%dns :Start Checking Submit multiple identical commands with different tags in Port1.\n",$time);

          repeat(4)
          begin
            assert (RandP1.randomize());
            DrivePort1.Add(50,22,RandP1.tag_maker());
          end
          repeat(10)@(posedge GlobalPort.clk);

          $write("%dns :End Checking Submit multiple identical commands with different tags in Port1.\n",$time);

        end
        7:
        begin
          repeat(3)
          begin
            assert(RandP1.randomize());
            RandP1.do_RandCase(100,50,50,0,0,0,0);
          end
          assert(RandP1.randomize());
          RandP1.do_RandCase(0,0,0,100,50,50,0);
        end
        8:
        begin
          repeat(4)
          begin
            assert(RandP1.randomize());
            RandP1.do_RandCase(100,50,50,0,0,0,0);
          end
        end
        9:
        begin
          repeat(3)
          begin
            assert(RandP1.randomize());
            RandP1.do_RandCase(0,0,0,100,50,50,0);
          end
          assert(RandP1.randomize());
          RandP1.do_RandCase(100,50,50,0,0,0,0);
        end
        10:
        begin
          repeat(4)
          begin
            assert(RandP1.randomize());
            RandP1.do_RandCase(0,0,0,100,50,50,0);
          end
        end
      endcase

    end
  endtask
  task testP2(int testcase_number =4, int make_test=20); // Test Case scenarios for Port2 with default test case number 4
    begin

      case(testcase_number)
        default: // Add and sub Testcases
        begin
          //Test cases for Add
          $write("%dns :Start Checking Add/Sub commands in Port2.\n",$time);

          DrivePort2.Add(50,22,0); // Simple Add test
          DrivePort2.Add(50,0, 1); // One operand is zero
          DrivePort2.Add(22,0, 2); // One operand is zero
          DrivePort2.Add(33,0, 3); // One operand is zero
          DrivePort2.Add(44,0, 0); // One operand is zero
          DrivePort2.Add(45,0, 1); // One operand is zero
          DrivePort2.Add(0,22, 2); // One operand is zero
          DrivePort2.Add(0,23, 3); // One operand is zero
          DrivePort2.Add(0,24, 0); // One operand is zero
          DrivePort2.Add(0,25, 1); // One operand is zero
          DrivePort2.Add(0,26, 2); // One operand is zero
          DrivePort2.Add(0, 0, 3); // two Operands is zero

          repeat(10)@(posedge GlobalPort.clk);

          assert(RandP2.randomize());
          DrivePort2.Add(RandP2.Inputs[0],RandP2.Inputs[1], 0); // make Add result exactly 'hFFFFFFFF
          assert(RandP2.randomize());
          DrivePort2.Add(RandP2.Inputs2[0],RandP2.Inputs2[1], 1); // Make Add overflow by 1
          //-------------------------------------------------------------------------------------------//

          repeat(10)@(posedge GlobalPort.clk);

          DrivePort2.Sub(50,22,2); // Simple Subtract test
          DrivePort2.Sub(50,0, 3); // One Operand is zero
          DrivePort2.Sub(40,0, 0); // One Operand is zero
          DrivePort2.Sub(20,0, 1); // One Operand is zero
          DrivePort2.Sub(10,0, 2); // One Operand is zero
          DrivePort2.Sub(15,0, 3); // One Operand is zero
          DrivePort2.Sub(0,22, 0); // One Operand is zero
          DrivePort2.Sub(0,24, 1); // One Operand is zero
          DrivePort2.Sub(0,25, 2); // One Operand is zero
          DrivePort2.Sub(0,26, 3); // One Operand is zero
          DrivePort2.Sub(0,28, 0); // One Operand is zero
          DrivePort2.Sub(0, 0, 1); // two Operands is zero

          repeat(10)@(posedge GlobalPort.clk);

          DrivePort2.Sub(50,50,2); // Two equal Operands in Sub
          DrivePort2.Sub(50,51,3); // Make Underflow by 1
          //--------------------------------------------------------------------------------------------//

          //----! Make Some Add/Sub commands that sake to Over/UnderFlow  !-----//
          repeat(10)@(posedge GlobalPort.clk);

          DrivePort2.Add('hEFFFFFEF,'h10000011,0);
          DrivePort2.Add('hEFFFFFEE,'h10000012,1);
          DrivePort2.Add('hEFFFFFED,'h10000013,2);
          DrivePort2.Add('hEFFFFFEC,'h10000014,3);
          DrivePort2.Add('hEFFFFFEB,'h10000015,0);
          DrivePort2.Sub(0,1,1);
          DrivePort2.Sub(1,2,2);
          DrivePort2.Sub(2,3,3);
          DrivePort2.Sub(3,4,0);
          DrivePort2.Sub(4,5,1);
          DrivePort2.Add('hFFFFFFFF,3,2);
          DrivePort2.Add('hFFFFFFFF,4,3);
          DrivePort2.Add('hFFFFFFFF,5,0);
          DrivePort2.Add('hFFFFFFFF,6,1);
          DrivePort2.Add('hFFFFFFFF,7,2);
          DrivePort2.Sub('hFFFFFFFC,'hFFFFFFFE,3);
          DrivePort2.Sub('hFFFFFFFb,'hFFFFFFFd,0);
          DrivePort2.Sub('hFFFFFFFa,'hFFFFFFFc,1);
          DrivePort2.Sub('hFFFFFFF9,'hFFFFFFFb,2);
          DrivePort2.Sub('hFFFFFFF8,'hFFFFFFFa,3);

          $write("%dns :End of Checking Add/Sub in Port2.\n",$time);
        end

        1:// Shift Testcases
        begin
          $write("%dns :Start Checking Shift Commands in Port2.\n",$time);

          DrivePort2.SHL('1,'0,0);            // Make Zero Shift Left
          DrivePort2.SHL(56,'0,1);            // Make Zero Shift Left
          DrivePort2.SHL(52,'0,2);            // Make Zero Shift Left
          DrivePort2.SHL(456,'0,3);           // Make Zero Shift Left
          DrivePort2.SHL(1225,'0,0);          // Make Zero Shift Left
          DrivePort2.SHL(1,32,1);             // Make 32 Shift Left
          DrivePort2.SHL(2,32,2);             // Make 32 Shift Left
          DrivePort2.SHL(15,32,3);            // Make 32 Shift Left
          DrivePort2.SHL(32,32,0);            // Make 32 Shift Left
          DrivePort2.SHL(45,32,1);            // Make 32 Shift Left
          DrivePort2.SHR('1,'0,2);            // Make Zero Shift Right
          DrivePort2.SHR(45,'0,3);            // Make Zero Shift Right
          DrivePort2.SHR(12,'0,0);            // Make Zero Shift Right
          DrivePort2.SHR(14,'0,1);            // Make Zero Shift Right
          DrivePort2.SHR(15,'0,2);            // Make Zero Shift Right
          DrivePort2.SHR('h10000000,5'b1,3);  // Make 32 Shift Right
          DrivePort2.SHR(535,5'b1,0);         // Make 32 Shift Right
          DrivePort2.SHR(632,5'b1,1);         // Make 32 Shift Right
          DrivePort2.SHR(425,5'b1,2);         // Make 32 Shift Right
          DrivePort2.SHR(200,5'b1,3);         // Make 32 Shift Right
          DrivePort2.SHL('he11d33e8,'h603a86c1,0);    // 1 bit overflow in left Shift
          DrivePort2.SHL('h097ec66a,'h8b3fed4a,1);    // 6 bit overflow in left Shift
          DrivePort2.SHL('1,'1,2);
          DrivePort2.SHR('1,'1,3);
          repeat(10)@(posedge GlobalPort.clk);

          //--------------------! Check the shift command on the zero operand !---------//

          repeat(2)
          begin
            assert(RandP2.randomize());
            DrivePort2.SHL('0,RandP2.Shift_Operand2,RandP2.tag_maker());
            assert(RandP2.randomize());
            DrivePort2.SHR('0,RandP2.Shift_Operand2,RandP2.tag_maker());
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //-------! Check the shift command on the second operand and the ignored values !--------//

          DrivePort2.SHL('hFFFFFFF0,'hFFFFFFE2, 0);
          DrivePort2.SHL('hFFFFFFF0,'hFEFEFEE1, 1);
          DrivePort2.SHL('hFFFFFFF0,'hFEFEFEE3, 2);
          DrivePort2.SHL('hFFFFFFF0,'hFEFEFEE4, 3);
          DrivePort2.SHL('hFFFFFFF0,'hFEFEFEE5, 0);
          DrivePort2.SHL('hFFFFFFF0,'hFEFEFEE6, 1);
          DrivePort2.SHR('h0FFFFFFF,'hFFFFFFE2, 2);
          DrivePort2.SHR('h0FFFFFFF,'hFEFEFEE1, 3);
          DrivePort2.SHR('h0FFFFFFF,'hFEFEFEE2, 0);
          DrivePort2.SHR('h0FFFFFFF,'hFEFEFEE3, 1);
          DrivePort2.SHR('h0FFFFFFF,'hFEFEFEE4, 2);
          DrivePort2.SHR('h0FFFFFFF,'hFEFEFEE5, 3);

          repeat(10)@(posedge GlobalPort.clk);

          $write("%dns :End of Checking Shift Commands in Port2.\n",$time);
        end

        2:
        begin
          $write("%dns :Start Checking the sequence and prioritize the execution of commands in Port2.\n",$time);
          //--------------! Make 3 Add/Sub and 1 Shift command at the end !-----------------------//
          repeat(3)
          begin
            assert(RandP2.randomize());
            RandP2.do_RandCase(100,50,50,0,0,0,0); // Make 3 Add/Sub command
          end
          assert(RandP2.randomize());
          RandP2.do_RandCase(0,0,0,100,50,50,0);  //Make Shift command
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          // -----------! Make 4 Add/Sub or Shift Commands with random order !--------------------//
          repeat(10)
          begin
            repeat(4)
            begin
              assert(RandP2.randomize());
              RandP2.do_RandCase(50,100,0,50,50,50,0);
            end
            repeat(10)@(posedge GlobalPort.clk);
          end
          $write("%dns :End of Checking the sequence and prioritize the execution of commands in Port2.\n",$time);
        end

        3:
        begin
          $write("%dns :Start Checking Test various schedules and unauthorized commands in Port2.\n",$time);
          //--------------! Make 8 Random Valid Command with Random Time interval !--------------//
          repeat(8)
          begin
            assert(RandP2.randomize());
            RandP2.full_random_valid_command();
            repeat(RandP2.time_delay)@(posedge GlobalPort.clk);
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //---------------! Make 4 Random invalid Command !-----------------------------//

          repeat(4)
          begin
            assert(RandP2.randomize());
            RandP2.full_random_invalid_command();
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //---------------! Send a combination of valid and invalid commands !----------//

          repeat(4)
          begin
            assert(RandP2.randomize());
            RandP2.full_random_valid_command();
            assert(RandP2.randomize());
            RandP2.full_random_invalid_command();
          end
          repeat(10)@(posedge GlobalPort.clk);

          $write("%dns :End of Checking Test various schedules and unauthorized commands in Port2.\n",$time);

        end
        4:
        begin
          $write("%dns :Start sending %0d random valid command in Port2.\n",$time,make_test*4);
          repeat(make_test)
          begin
            repeat(4)
            begin
              assert(RandP2.randomize());
              RandP2.full_random_valid_command();
            end
            assert(RandP2.randomize());
            repeat(RandP2.time_delay)@(posedge GlobalPort.clk);
          end
          $write("%dns :End of sending %0d random valid command in Port2.\n",$time,make_test*4);
        end


        5:
        begin
          $write("%dns :Start Checking Send multiple commands from the same port with the same tags in Port2.\n",$time);

          //-------! Send multiple commands from the same port with the same tags !------//

          repeat(2)
          begin
            assert(RandP2.randomize());
            DrivePort2.SHL(RandP2.Data1,RandP2.Shift_Operand2,0);
            assert(RandP2.randomize());
            DrivePort2.Add(RandP2.Data1,RandP2.Data2,0);
          end

          repeat(10)@(posedge GlobalPort.clk);

          repeat(2)
          begin
            assert(RandP2.randomize());
            DrivePort2.SHR(RandP2.Data1,RandP2.Shift_Operand2,1);
            assert(RandP2.randomize());
            DrivePort2.Add(RandP2.Data1,RandP2.Data2,1);
          end
          repeat(10)@(posedge GlobalPort.clk);

          repeat(2)
          begin
            assert(RandP2.randomize());
            DrivePort2.SHL(RandP2.Data1,RandP2.Shift_Operand2,2);
            assert(RandP1.randomize());
            DrivePort2.Add(RandP2.Data1,RandP2.Data2,2);
          end
          repeat(10)@(posedge GlobalPort.clk);

          repeat(2)
          begin
            assert(RandP2.randomize());
            DrivePort2.SHR(RandP2.Data1,RandP2.Shift_Operand2,3);
            assert(RandP2.randomize());
            DrivePort2.Add(RandP2.Data1,RandP2.Data2,3);
          end
          repeat(10)@(posedge GlobalPort.clk);

          $write("%dns :End of Checking Send multiple commands from the same port with the same tags in Port2.\n",$time);

        end
        6:
        begin
          $write("%dns :Start Checking Submit multiple identical commands with different tags in Port2.\n",$time);

          repeat(4)
          begin
            assert (RandP2.randomize());
            DrivePort2.Add(50,22,RandP2.tag_maker());
          end
          repeat(10)@(posedge GlobalPort.clk);

          $write("%dns :End Checking Submit multiple identical commands with different tags in Port2.\n",$time);

        end
        7:
        begin
          repeat(3)
          begin
            assert(RandP2.randomize());
            RandP2.do_RandCase(100,50,50,0,0,0,0);
          end
          assert(RandP2.randomize());
          RandP2.do_RandCase(0,0,0,100,50,50,0);
        end
        8:
        begin
          repeat(4)
          begin
            assert(RandP2.randomize());
            RandP2.do_RandCase(100,50,50,0,0,0,0);
          end
        end
        9:
        begin
          repeat(3)
          begin
            assert(RandP2.randomize());
            RandP2.do_RandCase(0,0,0,100,50,50,0);
          end
          assert(RandP2.randomize());
          RandP2.do_RandCase(100,50,50,0,0,0,0);
        end
        10:
        begin
          repeat(4)
          begin
            assert(RandP2.randomize());
            RandP2.do_RandCase(0,0,0,100,50,50,0);
          end
        end
      endcase

    end
  endtask
  task testP3(int testcase_number =4, int make_test=20); // Test Case scenarios for Port3 with default test case number 4
    begin

      case(testcase_number)
        default: // Add and sub Testcases
        begin
          //Test cases for Add
          $write("%dns :Start Checking Add/Sub commands in Port3.\n",$time);

          DrivePort3.Add(50,22,0); // Simple Add test
          DrivePort3.Add(50,0, 1); // One operand is zero
          DrivePort3.Add(22,0, 2); // One operand is zero
          DrivePort3.Add(33,0, 3); // One operand is zero
          DrivePort3.Add(44,0, 0); // One operand is zero
          DrivePort3.Add(45,0, 1); // One operand is zero
          DrivePort3.Add(0,22, 2); // One operand is zero
          DrivePort3.Add(0,23, 3); // One operand is zero
          DrivePort3.Add(0,24, 0); // One operand is zero
          DrivePort3.Add(0,25, 1); // One operand is zero
          DrivePort3.Add(0,26, 2); // One operand is zero
          DrivePort3.Add(0, 0, 3); // two Operands is zero

          repeat(10)@(posedge GlobalPort.clk);

          assert(RandP3.randomize());
          DrivePort3.Add(RandP3.Inputs[0],RandP3.Inputs[1], 0); // make Add result exactly 'hFFFFFFFF
          assert(RandP3.randomize());
          DrivePort3.Add(RandP3.Inputs2[0],RandP3.Inputs2[1], 1); // Make Add overflow by 1
          //-------------------------------------------------------------------------------------------//

          repeat(10)@(posedge GlobalPort.clk);

          DrivePort3.Sub(50,22,2); // Simple Subtract test
          DrivePort3.Sub(50,0, 3); // One Operand is zero
          DrivePort3.Sub(40,0, 0); // One Operand is zero
          DrivePort3.Sub(20,0, 1); // One Operand is zero
          DrivePort3.Sub(10,0, 2); // One Operand is zero
          DrivePort3.Sub(15,0, 3); // One Operand is zero
          DrivePort3.Sub(0,22, 0); // One Operand is zero
          DrivePort3.Sub(0,24, 1); // One Operand is zero
          DrivePort3.Sub(0,25, 2); // One Operand is zero
          DrivePort3.Sub(0,26, 3); // One Operand is zero
          DrivePort3.Sub(0,28, 0); // One Operand is zero
          DrivePort3.Sub(0, 0, 1); // two Operands is zero

          repeat(10)@(posedge GlobalPort.clk);

          DrivePort3.Sub(50,50,2); // Two equal Operands in Sub
          DrivePort3.Sub(50,51,3); // Make Underflow by 1
          //--------------------------------------------------------------------------------------------//

          //----! Make Some Add/Sub commands that sake to Over/UnderFlow  !-----//
          repeat(10)@(posedge GlobalPort.clk);

          DrivePort3.Add('hEFFFFFEF,'h10000011,0);
          DrivePort3.Add('hEFFFFFEE,'h10000012,1);
          DrivePort3.Add('hEFFFFFED,'h10000013,2);
          DrivePort3.Add('hEFFFFFEC,'h10000014,3);
          DrivePort3.Add('hEFFFFFEB,'h10000015,0);
          DrivePort3.Sub(0,1,1);
          DrivePort3.Sub(1,2,2);
          DrivePort3.Sub(2,3,3);
          DrivePort3.Sub(3,4,0);
          DrivePort3.Sub(4,5,1);
          DrivePort3.Add('hFFFFFFFF,3,2);
          DrivePort3.Add('hFFFFFFFF,4,3);
          DrivePort3.Add('hFFFFFFFF,5,0);
          DrivePort3.Add('hFFFFFFFF,6,1);
          DrivePort3.Add('hFFFFFFFF,7,2);
          DrivePort3.Sub('hFFFFFFFC,'hFFFFFFFE,3);
          DrivePort3.Sub('hFFFFFFFb,'hFFFFFFFd,0);
          DrivePort3.Sub('hFFFFFFFa,'hFFFFFFFc,1);
          DrivePort3.Sub('hFFFFFFF9,'hFFFFFFFb,2);
          DrivePort3.Sub('hFFFFFFF8,'hFFFFFFFa,3);


          $write("%dns :End of Checking Add/Sub in Port3.\n",$time);
        end

        1:// Shift Testcases
        begin
          $write("%dns :Start Checking Shift Commands in Port3.\n",$time);

          DrivePort3.SHL('1,'0,0);            // Make Zero Shift Left
          DrivePort3.SHL(56,'0,1);            // Make Zero Shift Left
          DrivePort3.SHL(52,'0,2);            // Make Zero Shift Left
          DrivePort3.SHL(456,'0,3);           // Make Zero Shift Left
          DrivePort3.SHL(1225,'0,0);          // Make Zero Shift Left
          DrivePort3.SHL(1,32,1);             // Make 32 Shift Left
          DrivePort3.SHL(2,32,2);             // Make 32 Shift Left
          DrivePort3.SHL(15,32,3);            // Make 32 Shift Left
          DrivePort3.SHL(32,32,0);            // Make 32 Shift Left
          DrivePort3.SHL(45,32,1);            // Make 32 Shift Left
          DrivePort3.SHR('1,'0,2);            // Make Zero Shift Right
          DrivePort3.SHR(45,'0,3);            // Make Zero Shift Right
          DrivePort3.SHR(12,'0,0);            // Make Zero Shift Right
          DrivePort3.SHR(14,'0,1);            // Make Zero Shift Right
          DrivePort3.SHR(15,'0,2);            // Make Zero Shift Right
          DrivePort3.SHR('h10000000,5'b1,3);  // Make 32 Shift Right
          DrivePort3.SHR(535,5'b1,0);         // Make 32 Shift Right
          DrivePort3.SHR(632,5'b1,1);         // Make 32 Shift Right
          DrivePort3.SHR(425,5'b1,2);         // Make 32 Shift Right
          DrivePort3.SHR(200,5'b1,3);         // Make 32 Shift Right
          DrivePort3.SHL('he11d33e8,'h603a86c1,0);     // 1 bit overflow in left Shift
          DrivePort3.SHL('h097ec66a,'h8b3fed4a,1);     // 6 bit overflow in left Shift
          DrivePort3.SHL('1,'1,2);
          DrivePort3.SHR('1,'1,3);
          repeat(10)@(posedge GlobalPort.clk);

          //--------------------! Check the shift command on the zero operand !---------//

          repeat(2)
          begin
            assert(RandP3.randomize());
            DrivePort3.SHL('0,RandP3.Shift_Operand2,RandP3.tag_maker());
            assert(RandP3.randomize());
            DrivePort3.SHR('0,RandP3.Shift_Operand2,RandP3.tag_maker());
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //-------! Check the shift command on the second operand and the ignored values !--------//

          DrivePort3.SHL('hFFFFFFF0,'hFFFFFFE2, 0);
          DrivePort3.SHL('hFFFFFFF0,'hFEFEFEE1, 1);
          DrivePort3.SHL('hFFFFFFF0,'hFEFEFEE3, 2);
          DrivePort3.SHL('hFFFFFFF0,'hFEFEFEE4, 3);
          DrivePort3.SHL('hFFFFFFF0,'hFEFEFEE5, 0);
          DrivePort3.SHL('hFFFFFFF0,'hFEFEFEE6, 1);
          DrivePort3.SHR('h0FFFFFFF,'hFFFFFFE2, 2);
          DrivePort3.SHR('h0FFFFFFF,'hFEFEFEE1, 3);
          DrivePort3.SHR('h0FFFFFFF,'hFEFEFEE2, 0);
          DrivePort3.SHR('h0FFFFFFF,'hFEFEFEE3, 1);
          DrivePort3.SHR('h0FFFFFFF,'hFEFEFEE4, 2);
          DrivePort3.SHR('h0FFFFFFF,'hFEFEFEE5, 3);

          repeat(10)@(posedge GlobalPort.clk);

          $write("%dns :End of Checking Shift Commands in Port3.\n",$time);
        end

        2:
        begin
          $write("%dns :Start Checking the sequence and prioritize the execution of commands in Port3.\n",$time);
          //--------------! Make 3 Add/Sub and 1 Shift command at the end !-----------------------//
          repeat(3)
          begin
            assert(RandP3.randomize());
            RandP3.do_RandCase(100,50,50,0,0,0,0); // Make 3 Add/Sub command
          end
          assert(RandP3.randomize());
          RandP3.do_RandCase(0,0,0,100,50,50,0);  //Make Shift command
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          // -----------! Make 4 Add/Sub or Shift Commands with random order !--------------------//
          repeat(10)
          begin
            repeat(4)
            begin
              assert(RandP3.randomize());
              RandP3.do_RandCase(50,100,0,50,50,50,0);
            end
            repeat(10)@(posedge GlobalPort.clk);
          end
          $write("%dns :End of Checking the sequence and prioritize the execution of commands in Port3.\n",$time);
        end

        3:
        begin
          $write("%dns :Start Checking Test various schedules and unauthorized commands in Port3.\n",$time);
          //--------------! Make 8 Random Valid Command with Random Time interval !--------------//
          repeat(8)
          begin
            assert(RandP3.randomize());
            RandP3.full_random_valid_command();
            repeat(RandP3.time_delay)@(posedge GlobalPort.clk);
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //---------------! Make 4 Random invalid Command !-----------------------------//

          repeat(4)
          begin
            assert(RandP3.randomize());
            RandP3.full_random_invalid_command();
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //---------------! Send a combination of valid and invalid commands !----------//

          repeat(4)
          begin
            assert(RandP3.randomize());
            RandP3.full_random_valid_command();
            assert(RandP3.randomize());
            RandP3.full_random_invalid_command();
          end
          repeat(10)@(posedge GlobalPort.clk);

          $write("%dns :End of Checking Test various schedules and unauthorized commands in Port3.\n",$time);

        end
        4:
        begin
          $write("%dns :Start sending %0d random valid command in Port3.\n",$time,make_test*4);
          repeat(make_test)
          begin
            repeat(4)
            begin
              assert(RandP3.randomize());
              RandP3.full_random_valid_command();
            end
            assert(RandP3.randomize());
            repeat(RandP3.time_delay)@(posedge GlobalPort.clk);
          end
          $write("%dns :End of sending %0d random valid command in Port3.\n",$time,make_test*4);
        end

        5:
        begin
          $write("%dns :Start Checking Send multiple commands from the same port with the same tags in Port3.\n",$time);

          //-------! Send multiple commands from the same port with the same tags !------//

          repeat(2)
          begin
            assert(RandP3.randomize());
            DrivePort3.SHL(RandP3.Data1,RandP3.Shift_Operand2,0);
            assert(RandP3.randomize());
            DrivePort3.Add(RandP3.Data1,RandP3.Data2,0);
          end

          repeat(10)@(posedge GlobalPort.clk);

          repeat(2)
          begin
            assert(RandP3.randomize());
            DrivePort3.SHR(RandP3.Data1,RandP3.Shift_Operand2,1);
            assert(RandP3.randomize());
            DrivePort3.Add(RandP3.Data1,RandP3.Data2,1);
          end
          repeat(10)@(posedge GlobalPort.clk);

          repeat(2)
          begin
            assert(RandP3.randomize());
            DrivePort3.SHL(RandP3.Data1,RandP3.Shift_Operand2,2);
            assert(RandP1.randomize());
            DrivePort3.Add(RandP3.Data1,RandP3.Data2,2);
          end
          repeat(10)@(posedge GlobalPort.clk);

          repeat(2)
          begin
            assert(RandP3.randomize());
            DrivePort3.SHR(RandP3.Data1,RandP3.Shift_Operand2,3);
            assert(RandP3.randomize());
            DrivePort3.Add(RandP3.Data1,RandP3.Data2,3);
          end
          repeat(10)@(posedge GlobalPort.clk);

          $write("%dns :End of Checking Send multiple commands from the same port with the same tags in Port3.\n",$time);

        end
        6:
        begin
          $write("%dns :Start Checking Submit multiple identical commands with different tags in Port3.\n",$time);

          repeat(4)
          begin
            assert (RandP3.randomize());
            DrivePort3.Add(50,22,RandP3.tag_maker());
          end
          repeat(10)@(posedge GlobalPort.clk);

          $write("%dns :End Checking Submit multiple identical commands with different tags in Port3.\n",$time);

        end
        7:
        begin
          repeat(3)
          begin
            assert(RandP3.randomize());
            RandP3.do_RandCase(100,50,50,0,0,0,0);
          end
          assert(RandP3.randomize());
          RandP3.do_RandCase(0,0,0,100,50,50,0);
        end
        8:
        begin
          repeat(4)
          begin
            assert(RandP3.randomize());
            RandP3.do_RandCase(100,50,50,0,0,0,0);
          end
        end
        9:
        begin
          repeat(3)
          begin
            assert(RandP3.randomize());
            RandP3.do_RandCase(0,0,0,100,50,50,0);
          end
          assert(RandP3.randomize());
          RandP3.do_RandCase(100,50,50,0,0,0,0);
        end
        10:
        begin
          repeat(4)
          begin
            assert(RandP3.randomize());
            RandP3.do_RandCase(0,0,0,100,50,50,0);
          end
        end
      endcase

    end
  endtask

  task testP4(int testcase_number =4, int make_test=20); // Test Case scenarios for Port4 with default test case number 4
    begin

      case(testcase_number)
        default: // Add and sub Testcases
        begin
          //Test cases for Add
          $write("%dns :Start Checking Add/Sub commands in Port4.\n",$time);

          DrivePort4.Add(50,22,0); // Simple Add test
          DrivePort4.Add(50,0, 1); // One operand is zero
          DrivePort4.Add(22,0, 2); // One operand is zero
          DrivePort4.Add(33,0, 3); // One operand is zero
          DrivePort4.Add(44,0, 0); // One operand is zero
          DrivePort4.Add(45,0, 1); // One operand is zero
          DrivePort4.Add(0,22, 2); // One operand is zero
          DrivePort4.Add(0,23, 3); // One operand is zero
          DrivePort4.Add(0,24, 0); // One operand is zero
          DrivePort4.Add(0,25, 1); // One operand is zero
          DrivePort4.Add(0,26, 2); // One operand is zero
          DrivePort4.Add(0, 0, 3); // two Operands is zero

          repeat(10)@(posedge GlobalPort.clk);

          assert(RandP4.randomize());
          DrivePort4.Add(RandP4.Inputs[0],RandP4.Inputs[1], 0); // make Add result exactly 'hFFFFFFFF
          assert(RandP4.randomize());
          DrivePort4.Add(RandP4.Inputs2[0],RandP4.Inputs2[1], 1); // Make Add overflow by 1
          //-------------------------------------------------------------------------------------------//

          repeat(10)@(posedge GlobalPort.clk);

          DrivePort4.Sub(50,22,2); // Simple Subtract test
          DrivePort4.Sub(50,0, 3); // One Operand is zero
          DrivePort4.Sub(40,0, 0); // One Operand is zero
          DrivePort4.Sub(20,0, 1); // One Operand is zero
          DrivePort4.Sub(10,0, 2); // One Operand is zero
          DrivePort4.Sub(15,0, 3); // One Operand is zero
          DrivePort4.Sub(0,22, 0); // One Operand is zero
          DrivePort4.Sub(0,24, 1); // One Operand is zero
          DrivePort4.Sub(0,25, 2); // One Operand is zero
          DrivePort4.Sub(0,26, 3); // One Operand is zero
          DrivePort4.Sub(0,28, 0); // One Operand is zero
          DrivePort4.Sub(0, 0, 1); // two Operands is zero

          repeat(10)@(posedge GlobalPort.clk);

          DrivePort4.Sub(50,50,2); // Two equal Operands in Sub
          DrivePort4.Sub(50,51,3); // Make Underflow by 1
          //--------------------------------------------------------------------------------------------//

          //----! Make Some Add/Sub commands that sake to Over/UnderFlow  !-----//
          repeat(10)@(posedge GlobalPort.clk);

          DrivePort4.Add('hEFFFFFEF,'h10000011,0);
          DrivePort4.Add('hEFFFFFEE,'h10000012,1);
          DrivePort4.Add('hEFFFFFED,'h10000013,2);
          DrivePort4.Add('hEFFFFFEC,'h10000014,3);
          DrivePort4.Add('hEFFFFFEB,'h10000015,0);
          DrivePort4.Sub(0,1,1);
          DrivePort4.Sub(1,2,2);
          DrivePort4.Sub(2,3,3);
          DrivePort4.Sub(3,4,0);
          DrivePort4.Sub(4,5,1);
          DrivePort4.Add('hFFFFFFFF,3,2);
          DrivePort4.Add('hFFFFFFFF,4,3);
          DrivePort4.Add('hFFFFFFFF,5,0);
          DrivePort4.Add('hFFFFFFFF,6,1);
          DrivePort4.Add('hFFFFFFFF,7,2);
          DrivePort4.Sub('hFFFFFFFC,'hFFFFFFFE,3);
          DrivePort4.Sub('hFFFFFFFb,'hFFFFFFFd,0);
          DrivePort4.Sub('hFFFFFFFa,'hFFFFFFFc,1);
          DrivePort4.Sub('hFFFFFFF9,'hFFFFFFFb,2);
          DrivePort4.Sub('hFFFFFFF8,'hFFFFFFFa,3);


          $write("%dns :End of Checking Add/Sub in Port4.\n",$time);
        end

        1:// Shift Testcases
        begin
          $write("%dns :Start Checking Shift Commands in Port4.\n",$time);

          DrivePort4.SHL('1,'0,0);            // Make Zero Shift Left
          DrivePort4.SHL(56,'0,1);            // Make Zero Shift Left
          DrivePort4.SHL(52,'0,2);            // Make Zero Shift Left
          DrivePort4.SHL(456,'0,3);           // Make Zero Shift Left
          DrivePort4.SHL(1225,'0,0);          // Make Zero Shift Left
          DrivePort4.SHL(1,32,1);             // Make 32 Shift Left
          DrivePort4.SHL(2,32,2);             // Make 32 Shift Left
          DrivePort4.SHL(15,32,3);            // Make 32 Shift Left
          DrivePort4.SHL(32,32,0);            // Make 32 Shift Left
          DrivePort4.SHL(45,32,1);            // Make 32 Shift Left
          DrivePort4.SHR('1,'0,2);            // Make Zero Shift Right
          DrivePort4.SHR(45,'0,3);            // Make Zero Shift Right
          DrivePort4.SHR(12,'0,0);            // Make Zero Shift Right
          DrivePort4.SHR(14,'0,1);            // Make Zero Shift Right
          DrivePort4.SHR(15,'0,2);            // Make Zero Shift Right
          DrivePort4.SHR('h10000000,5'b1,3);  // Make 32 Shift Right
          DrivePort4.SHR(535,5'b1,0);         // Make 32 Shift Right
          DrivePort4.SHR(632,5'b1,1);         // Make 32 Shift Right
          DrivePort4.SHR(425,5'b1,2);         // Make 32 Shift Right
          DrivePort4.SHR(200,5'b1,3);         // Make 32 Shift Right
          DrivePort4.SHL('he11d33e8,'h603a86c1,0);    // 1 bit overflow in left Shift
          DrivePort4.SHL('h097ec66a,'h8b3fed4a,1);    // 6 bit overflow in left Shift
          DrivePort4.SHL('1,'1,2);
          DrivePort4.SHR('1,'1,3);
          repeat(10)@(posedge GlobalPort.clk);
          //--------------------! Check the shift command on the zero operand !---------//

          repeat(2)
          begin
            assert(RandP4.randomize());
            DrivePort4.SHL('0,RandP4.Shift_Operand2,RandP4.tag_maker());
            assert(RandP1.randomize());
            DrivePort4.SHR('0,RandP4.Shift_Operand2,RandP4.tag_maker());
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //-------! Check the shift command on the second operand and the ignored values !--------//

          DrivePort4.SHL('hFFFFFFF0,'hFFFFFFE2, 0);
          DrivePort4.SHL('hFFFFFFF0,'hFEFEFEE1, 1);
          DrivePort4.SHL('hFFFFFFF0,'hFEFEFEE3, 2);
          DrivePort4.SHL('hFFFFFFF0,'hFEFEFEE4, 3);
          DrivePort4.SHL('hFFFFFFF0,'hFEFEFEE5, 0);
          DrivePort4.SHL('hFFFFFFF0,'hFEFEFEE6, 1);
          DrivePort4.SHR('h0FFFFFFF,'hFFFFFFE2, 2);
          DrivePort4.SHR('h0FFFFFFF,'hFEFEFEE1, 3);
          DrivePort4.SHR('h0FFFFFFF,'hFEFEFEE2, 0);
          DrivePort4.SHR('h0FFFFFFF,'hFEFEFEE3, 1);
          DrivePort4.SHR('h0FFFFFFF,'hFEFEFEE4, 2);
          DrivePort4.SHR('h0FFFFFFF,'hFEFEFEE5, 3);

          repeat(10)@(posedge GlobalPort.clk);

          $write("%dns :End of Checking Shift Commands in Port4.\n",$time);
        end

        2:
        begin
          $write("%dns :Start Checking the sequence and prioritize the execution of commands in Port4.\n",$time);
          //--------------! Make 3 Add/Sub and 1 Shift command at the end !-----------------------//
          repeat(3)
          begin
            assert(RandP4.randomize());
            RandP4.do_RandCase(100,50,50,0,0,0,0); // Make 3 Add/Sub command
          end
          assert(RandP4.randomize());
          RandP4.do_RandCase(0,0,0,100,50,50,0);  //Make Shift command
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          // -----------! Make 4 Add/Sub or Shift Commands with random order !--------------------//
          repeat(10)
          begin
            repeat(4)
            begin
              assert(RandP4.randomize());
              RandP4.do_RandCase(50,100,0,50,50,50,0);
            end
            repeat(10)@(posedge GlobalPort.clk);
          end
          $write("%dns :End of Checking the sequence and prioritize the execution of commands in Port4.\n",$time);
        end

        3:
        begin
          $write("%dns :Start Checking Test various schedules and unauthorized commands in Port4.\n",$time);
          //--------------! Make 8 Random Valid Command with Random Time interval !--------------//
          repeat(8)
          begin
            assert(RandP4.randomize());
            RandP4.full_random_valid_command();
            repeat(RandP4.time_delay)@(posedge GlobalPort.clk);
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //---------------! Make 4 Random invalid Command !-----------------------------//

          repeat(4)
          begin
            assert(RandP4.randomize());
            RandP4.full_random_invalid_command();
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //---------------! Send a combination of valid and invalid commands !----------//

          repeat(4)
          begin
            assert(RandP4.randomize());
            RandP4.full_random_valid_command();
            assert(RandP4.randomize());
            RandP4.full_random_invalid_command();
          end
          repeat(10)@(posedge GlobalPort.clk);

          $write("%dns :End of Checking Test various schedules and unauthorized commands in Port4.\n",$time);

        end
        4:
        begin
          $write("%dns :Start sending %0d random valid command in Port4.\n",$time,make_test*4);
          repeat(make_test)
          begin
            repeat(4)
            begin
              assert(RandP4.randomize());
              RandP4.full_random_valid_command();
            end
            assert(RandP4.randomize());
            repeat(RandP4.time_delay)@(posedge GlobalPort.clk);
          end
          $write("%dns :End of sending %0d random valid command in Port4.\n",$time,make_test*4);
        end

        5:
        begin
          $write("%dns :Start Checking Send multiple commands from the same port with the same tags in Port4.\n",$time);

          //-------! Send multiple commands from the same port with the same tags !------//

          repeat(2)
          begin
            assert(RandP4.randomize());
            DrivePort4.SHL(RandP4.Data1,RandP4.Shift_Operand2,0);
            assert(RandP4.randomize());
            DrivePort4.Add(RandP4.Data1,RandP4.Data2,0);
          end

          repeat(10)@(posedge GlobalPort.clk);

          repeat(2)
          begin
            assert(RandP4.randomize());
            DrivePort4.SHR(RandP4.Data1,RandP4.Shift_Operand2,1);
            assert(RandP4.randomize());
            DrivePort4.Add(RandP4.Data1,RandP4.Data2,1);
          end
          repeat(10)@(posedge GlobalPort.clk);

          repeat(2)
          begin
            assert(RandP4.randomize());
            DrivePort4.SHL(RandP4.Data1,RandP4.Shift_Operand2,2);
            assert(RandP1.randomize());
            DrivePort4.Add(RandP4.Data1,RandP4.Data2,2);
          end
          repeat(10)@(posedge GlobalPort.clk);

          repeat(2)
          begin
            assert(RandP4.randomize());
            DrivePort4.SHR(RandP4.Data1,RandP4.Shift_Operand2,3);
            assert(RandP4.randomize());
            DrivePort4.Add(RandP4.Data1,RandP4.Data2,3);
          end
          repeat(10)@(posedge GlobalPort.clk);

          $write("%dns :End of Checking Send multiple commands from the same port with the same tags in Port4.\n",$time);

        end
        6:
        begin
          $write("%dns :Start Checking Submit multiple identical commands with different tags in Port4.\n",$time);

          repeat(4)
          begin
            assert (RandP4.randomize());
            DrivePort4.Add(50,22,RandP4.tag_maker());
          end
          repeat(10)@(posedge GlobalPort.clk);

          $write("%dns :End Checking Submit multiple identical commands with different tags in Port4.\n",$time);

        end
        7:
        begin
          repeat(3)
          begin
            assert(RandP4.randomize());
            RandP4.do_RandCase(100,50,50,0,0,0,0);
          end
          assert(RandP4.randomize());
          RandP4.do_RandCase(0,0,0,100,50,50,0);
        end
        8:
        begin
          repeat(4)
          begin
            assert(RandP4.randomize());
            RandP4.do_RandCase(100,50,50,0,0,0,0);
          end
        end
        9:
        begin
          repeat(3)
          begin
            assert(RandP4.randomize());
            RandP4.do_RandCase(0,0,0,100,50,50,0);
          end
          assert(RandP4.randomize());
          RandP4.do_RandCase(100,50,50,0,0,0,0);
        end
        10:
        begin
          repeat(4)
          begin
            assert(RandP4.randomize());
            RandP4.do_RandCase(0,0,0,100,50,50,0);
          end
        end
      endcase

    end
  endtask


  task Make_Shift_out_of_order_result (); // Make out of order Shift result in all ports
    IReset();
    @(posedge GlobalPort.clk);
    GlobalPort.reset = 0;
    $write("%dns : Make_Shift_out_of_order_result Test activated\n",$time);
    fork
      testP1(7);
      testP2(8);
      testP3(8);
      testP4(8);
    join
    repeat(10)@(posedge GlobalPort.clk);

    fork
      testP1(8);
      testP2(7);
      testP3(8);
      testP4(8);
    join
    repeat(10)@(posedge GlobalPort.clk);

    fork
      testP1(8);
      testP2(8);
      testP3(7);
      testP4(8);
    join
    repeat(10)@(posedge GlobalPort.clk);

    fork
      testP1(8);
      testP2(8);
      testP3(8);
      testP4(7);
    join
    repeat(10)@(posedge GlobalPort.clk);

    $write("%dns : Make_Shift_out_of_order_result Test deactivated\n",$time);
  endtask
  task Make_AddSub_out_of_order_result (); // Make out of order AddSub result in all ports
    IReset();
    @(posedge GlobalPort.clk);
    GlobalPort.reset = 0;
    $write("%dns : Make_AddSub_out_of_order_result Test activated\n",$time);
    fork
      testP1(9);
      testP2(10);
      testP3(10);
      testP4(10);
    join
    repeat(10)@(posedge GlobalPort.clk);

    fork
      testP1(10);
      testP2(9);
      testP3(10);
      testP4(10);
    join
    repeat(10)@(posedge GlobalPort.clk);

    fork
      testP1(10);
      testP2(10);
      testP3(9);
      testP4(10);
    join
    repeat(10)@(posedge GlobalPort.clk);

    fork
      testP1(10);
      testP2(10);
      testP3(10);
      testP4(9);
    join
    repeat(10)@(posedge GlobalPort.clk);

    $write("%dns : Make_AddSub_out_of_order_result Test deactivated\n",$time);
  endtask

  task SimultaneousStaticTest ();// SimultaneousStaticTest testing of all ports with a static scenarios
    for(int state=0;state<10;state ++)
    begin
      for(int case_sel=0;case_sel<4;case_sel++)
      begin
        IReset();
        @(posedge GlobalPort.clk);
        GlobalPort.reset     = 0;
        $write("%dns : SimultaneousStaticTest activated\n",$time);

        case(state)
          default:
          begin
            fork
              testP1(case_sel);
              testP2(case_sel);
            join
          end
          1:
          begin
            fork
              testP1(case_sel);
              testP3(case_sel);
            join
          end
          2:
          begin
            fork
              testP1(case_sel);
              testP4(case_sel);
            join
          end
          3:
          begin
            fork
              testP2(case_sel);
              testP3(case_sel);
            join
          end
          4:
          begin
            fork
              testP2(case_sel);
              testP4(case_sel);
            join
          end
          5:
          begin
            fork
              testP1(case_sel);
              testP2(case_sel);
              testP3(case_sel);
            join
          end
          6:
          begin
            fork
              testP1(case_sel);
              testP2(case_sel);
              testP4(case_sel);
            join
          end
          7:
          begin
            fork
              testP1(case_sel);
              testP4(case_sel);
              testP3(case_sel);
            join
          end
          8:
          begin
            fork
              testP4(case_sel);
              testP2(case_sel);
              testP3(case_sel);
            join
          end
          9:
          begin
            fork
              testP1(case_sel);
              testP2(case_sel);
              testP3(case_sel);
              testP4(case_sel);
            join
          end
        endcase
        repeat(10)@(posedge GlobalPort.clk);
      end
    end
    $write("%dns : SimultaneousStaticTest deactivated\n",$time);

  endtask


endclass //Generator
