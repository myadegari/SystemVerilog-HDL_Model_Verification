`include "sv_Interfaces.sv"
`include "Driver.sv"
`include "Make_Random.sv"
//`include "LFSR.sv"

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
      this.Finish  = _Finish;

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
    Random_Test_Selector();
    $write("%dns : Generator finished\n",$time);
  endtask //

  task Simultaneous_Test (); // Simultaneous testing of all ports with a common scenario
   /* IReset();
    @(posedge GlobalPort.clk);
    GlobalPort.reset     = 0;*/
    $write("%dns : Simultaneous Test activated\n",$time);
    assert(RandGlobal.randomize());
    fork
      testP1(RandGlobal.Case_selector);
      testP2(RandGlobal.Case_selector);
      testP3(RandGlobal.Case_selector);
      testP4(RandGlobal.Case_selector);
    join
    repeat(10)@(posedge GlobalPort.clk);
    $write("%dns : Simultaneous Test deactivated\n",$time);

  endtask
  

  task Separate_Test (); //Run different and random scenarios separately on ports
   /* IReset();
    @(posedge GlobalPort.clk);
    GlobalPort.reset     = 0;*/
      $write("%dns : Seperate Test activated\n",$time);
      assert(RandGlobal.randomize());
      testP1(RandGlobal.Case_selector);

      repeat(5)@(posedge GlobalPort.clk); // Maked Delay between Tests

      assert(RandGlobal.randomize());
      testP2(RandGlobal.Case_selector);
      repeat(5)@(posedge GlobalPort.clk);

      assert(RandGlobal.randomize());
      testP3(RandGlobal.Case_selector);
      repeat(5)@(posedge GlobalPort.clk);

      assert(RandGlobal.randomize());
      testP4(RandGlobal.Case_selector);

    repeat(10)@(posedge GlobalPort.clk);
    $write("%dns : Seperate Test deactivated\n",$time);
  endtask


  task Random_Test_Selector();

      $write("%dns: Start Random Test Selector\n",$time);
      // repeat(10)begin

      IReset();
      @(posedge GlobalPort.clk);
      GlobalPort.reset     = 0;

      //assert(RandGlobal.randomize());
      case(1)//(RandGlobal.test_selector)

        1: testP1();//(RandGlobal.Case_selector);
        2: testP2(RandGlobal.Case_selector);
        3: testP3(RandGlobal.Case_selector);
        4: testP4(RandGlobal.Case_selector);
        5: Simultaneous_Test();
        6: Make_out_of_order_result ();
        default: Separate_Test();

      endcase

    // end
    $write("%dns: End Random Test Selector\n",$time);
    repeat(10)@(posedge GlobalPort.clk);
    ->Finish;
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

      GlobalPort.reset   = 1;
      $write("%dns : Reset asserted\n",$time);
      repeat(remain)@(posedge GlobalPort.clk);
      $write("%dns : Reset disasserted\n",$time);
    end
  endtask



  task testP1(int testcase_number =1); // Test Case scenarios for Port1 with default test case number 1
    begin

      case(testcase_number)
        1: // Add and sub Testcases
        begin
          //Test cases for Add
          $write("%dns :Start Checking Add/Sub commands in Port1.\n",$time);

          DrivePort1.Add(50,22,0); // Simple Add test
          DrivePort1.Add(50,0, 1); // One operand is zero
          DrivePort1.Add(0,22, 2); // One operand is zero
          DrivePort1.Add(0, 0, 3); // two Operands is zero

          repeat(10)@(posedge GlobalPort.clk);

          assert(RandP1.randomize());
          DrivePort1.Add(RandP1.Inputs[0],RandP1.Inputs[1], 0); // make Add result exactly 'hFFFFFFFF
          //assert(RandP1.randomize());
          //DrivePort1.Add(RandP1.Inputs2[0],RandP1.Inputs2[1], 1); // Make Add overflow by 1
          // make change
          DrivePort1.Add('hFFFFFFFF,'h00000011, 1); // Make Add overflow by 1
          //-------------------------------------------------------------------------------------------//
          
          repeat(10)@(posedge GlobalPort.clk);
          
          DrivePort1.Sub(50,22,2); // Simple Subtract test
          DrivePort1.Sub(50,0, 3); // One Operand is zero
          DrivePort1.Sub(0,22, 0); // One Operand is zero
          DrivePort1.Sub(0, 0, 1); // two Operands is zero
          DrivePort1.Sub(50,50,2); // Two equal Operands in Sub 
          DrivePort1.Sub(50,51,3); // Make Underflow by 1
          //--------------------------------------------------------------------------------------------//

          //----! Make Some Add/Sub commands that sake to Over/UnderFlow  !-----//
          repeat(10)@(posedge GlobalPort.clk);

          DrivePort1.Add('hEFFFFFEF,'h10000011,0);
          DrivePort1.Sub(0,1,1);
          DrivePort1.Add('hFFFFFFFF,3,2);
          DrivePort1.Sub('hFFFFFFFC,'hFFFFFFFE,3);

          $write("%dns :End of Checking Add/Sub in Port1.\n",$time);
        end

        2:// Shift Testcases
        begin
          $write("%dns :Start Checking Shift Commands in Port1.\n",$time);

          DrivePort1.SHL('hFFFFFFFF,0,0);            // Make Zero Shift Left
          DrivePort1.SHL(1,32,1);                    // Make 32 Shift Left
          DrivePort1.SHR('hFFFFFFFF,0,2);            // Make Zero Shift Right
          DrivePort1.SHR('h10000000,32,3);           // Make 32 Shift Right
          repeat(10)@(posedge GlobalPort.clk);

          //--------------------! Check the shift command on the zero operand !---------//

          repeat(2) begin
          assert(RandP1.randomize());
          DrivePort1.SHL(0,RandP1.Shift_Operand2,RandP1.Tag);
          assert(RandP1.randomize());
          DrivePort1.SHR(0,RandP1.Shift_Operand2,RandP1.Tag);
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //-------! Check the shift command on the second operand and the ignored values !--------//
         
          DrivePort1.SHL('hFFFFFFF0,'hFFFFFFE2, 0);
          DrivePort1.SHL('hFFFFFFF0,'hFEFEFEE1, 1);
          DrivePort1.SHR('h0FFFFFFF,'hFFFFFFE2, 2);
          DrivePort1.SHR('h0FFFFFFF,'hFEFEFEE1, 3);

          $write("%dns :End of Checking Shift Commands in Port1.\n",$time);
        end

        3:
        begin
          $write("%dns :Start Checking the sequence and prioritize the execution of commands in Port1.\n",$time);
          //--------------! Make 3 Add/Sub and 1 Shift command at the end !-----------------------//
          repeat(3)begin
          assert(RandP1.randomize());
            RandP1.do_RandCase(100,50,50,0,0,0,0);
          end
          assert(RandP1.randomize());
          RandP1.do_RandCase(0,0,0,100,50,50,0);
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          // -----------! Make 4 Add/Sub or Shift Commands with random order !--------------------// 

          repeat(4)begin
            assert(RandP1.randomize());
            RandP1.do_RandCase(50,100,0,50,50,50,0);
          end
        $write("%dns :End of Checking the sequence and prioritize the execution of commands in Port1.\n",$time);
        end

        4:
        begin
        $write("%dns :Start Checking Test various schedules and unauthorized commands in Port1.\n",$time);
          //--------------! Make 8 Random Valid Command with Random Time interval !--------------// 
          repeat(8)begin
            assert(RandP1.randomize());
            RandP1.full_random_valid_command(0);
            repeat(RandP1.Commandi)@(posedge GlobalPort.clk);
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //---------------! Make 4 Random invalid Command !-----------------------------//
          
          repeat(4)begin
            assert(RandP1.randomize());
            RandP1.full_random_invalid_command(0);
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //---------------! Send a combination of valid and invalid commands !----------// 

          repeat(4)begin
            assert(RandP1.randomize());
            RandP1.full_random_valid_command(1);
            assert(RandP1.randomize());
            RandP1.full_random_invalid_command(0);
          end
        $write("%dns :End of Checking Test various schedules and unauthorized commands in Port1.\n",$time);

        end
        // 
        5:
        begin
        $write("%dns :Start Checking Send multiple commands from the same port with the same tags in Port1.\n",$time);

          //-------! Send multiple commands from the same port with the same tags !------//

          repeat(2) begin
          assert(RandP1.randomize());
          DrivePort1.SHL(RandP1.Data1,RandP1.Shift_Operand2,0);
          assert(RandP1.randomize());
          DrivePort1.Add(RandP1.Data1,RandP1.Data2,0);
          end
          repeat(2) begin
          assert(RandP1.randomize());
          DrivePort1.SHR(RandP1.Data1,RandP1.Shift_Operand2,1);
          assert(RandP1.randomize());
          DrivePort1.Add(RandP1.Data1,RandP1.Data2,1);
          end
          repeat(2) begin
          assert(RandP1.randomize());
          DrivePort1.SHL(RandP1.Data1,RandP1.Shift_Operand2,2);
          assert(RandP1.randomize());
          DrivePort1.Add(RandP1.Data1,RandP1.Data2,2);
          end
          repeat(2) begin
          assert(RandP1.randomize());
          DrivePort1.SHR(RandP1.Data1,RandP1.Shift_Operand2,3);
          assert(RandP1.randomize());
          DrivePort1.Add(RandP1.Data1,RandP1.Data2,3);
          end
        $write("%dns :End of Checking Send multiple commands from the same port with the same tags in Port1.\n",$time);
        end

        6:
        begin
        $write("%dns :Start Checking Submit multiple identical commands with different tags in Port1.\n",$time);

          repeat(4)begin
            assert (RandP1.randomize());
            DrivePort1.Add(50,22,RandP1.Tag); 
          end
        $write("%dns :Start Checking Submit multiple identical commands with different tags in Port1.\n",$time);
        end

    
      endcase

    end
  endtask
  task testP2(int testcase_number=1); // Test Case scenarios for Port2 with default test case number 1
    begin

      case(testcase_number)
        1: // Add and sub Testcases
        begin
          //Test cases for Add
          $write("%dns :Start Checking Add/Sub commands in Port2.\n",$time);

          DrivePort2.Add(50,22,0); // Simple Add test
          DrivePort2.Add(50,0, 1); // One operand is zero
          DrivePort2.Add(0,22, 2); // One operand is zero
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
          DrivePort2.Sub(0,22, 0); // One Operand is zero
          DrivePort2.Sub(0, 0, 1); // two Operands is zero
          DrivePort2.Sub(50,50,2); // Two equal Operands in Sub 
          DrivePort2.Sub(50,51,3); // Make Underflow by 1
          //--------------------------------------------------------------------------------------------//

          //----! Make Some Add/Sub commands that sake to Over/UnderFlow  !-----//
          repeat(10)@(posedge GlobalPort.clk);
          DrivePort2.Add('hEFFFFFEF,'h10000011,0);
          DrivePort2.Sub(0,1,1);
          DrivePort2.Add('hFFFFFFFF,3,2);
          DrivePort2.Sub('hFFFFFFFC,'hFFFFFFFE,3);

          $write("%dns :End of Checking Add/Sub in Port2.\n",$time);
        end

        2:// Shift Testcases
        begin
          $write("%dns :Start Checking Shift Commands in Port2.\n",$time);

          DrivePort2.SHL('hFFFFFFFF,0,0);            // Make Zero Shift Left
          DrivePort2.SHL(1,32,1);                    // Make 32 Shift Left
          DrivePort2.SHR('hFFFFFFFF,0,2);            // Make Zero Shift Right
          DrivePort2.SHR('h10000000,32,3);           // Make 32 Shift Right
          repeat(10)@(posedge GlobalPort.clk);

          //--------------------! Check the shift command on the zero operand !---------//

          repeat(2) begin
          assert(RandP2.randomize());
          DrivePort2.SHL(0,RandP2.Shift_Operand2,RandP2.Tag);
          assert(RandP2.randomize());
          DrivePort2.SHR(0,RandP2.Shift_Operand2,RandP2.Tag);
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //-------! Check the shift command on the second operand and the ignored values !--------//
         
          DrivePort2.SHL('hFFFFFFF0,'hFFFFFFE2, 0);
          DrivePort2.SHL('hFFFFFFF0,'hFEFEFEE1, 1);
          DrivePort2.SHR('h0FFFFFFF,'hFFFFFFE2, 2);
          DrivePort2.SHR('h0FFFFFFF,'hFEFEFEE1, 3);

          $write("%dns :End of Checking Shift Commands in Port2.\n",$time);
        end

        3:
        begin
          $write("%dns :Start Checking the sequence and prioritize the execution of commands in Port2.\n",$time);
          //--------------! Make 3 Add/Sub and 1 Shift command at the end !-----------------------//
          repeat(3)begin
          assert(RandP2.randomize());
            RandP2.do_RandCase(100,50,50,0,0,0,0);
          end
          assert(RandP2.randomize());
          RandP2.do_RandCase(0,0,0,100,50,50,0);
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          // -----------! Make 4 Add/Sub or Shift Commands with random order !--------------------// 

          repeat(4)begin
            assert(RandP2.randomize());
            RandP2.do_RandCase(50,100,0,50,50,50,0);
          end
        $write("%dns :End of Checking the sequence and prioritize the execution of commands in Port2.\n",$time);
        end

        4:
        begin
        $write("%dns :Start Checking Test various schedules and unauthorized commands in Port2.\n",$time);
          //--------------! Make 8 Random Valid Command with Random Time interval !--------------// 
          repeat(8)begin
            assert(RandP2.randomize());
            RandP2.full_random_valid_command(0);
            repeat(RandP2.Commandi)@(posedge GlobalPort.clk);
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //---------------! Make 4 Random invalid Command !-----------------------------//
          
          repeat(4)begin
            assert(RandP2.randomize());
            RandP2.full_random_invalid_command(0);
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //---------------! Send a combination of valid and invalid commands !----------// 

          repeat(4)begin
            assert(RandP2.randomize());
            RandP2.full_random_valid_command(1);
            assert(RandP2.randomize());
            RandP2.full_random_invalid_command(0);
          end
        $write("%dns :End of Checking Test various schedules and unauthorized commands in Port2.\n",$time);

        end
        // 
        5:
        begin
        $write("%dns :Start Checking Send multiple commands from the same port with the same tags in Port2.\n",$time);

          //-------! Send multiple commands from the same port with the same tags !------//

          repeat(2) begin
          assert(RandP2.randomize());
          DrivePort2.SHL(RandP1.Data1,RandP2.Shift_Operand2,0);
          assert(RandP1.randomize());
          DrivePort2.Add(RandP2.Data1,RandP2.Data2,0);
          end
          repeat(2) begin
          assert(RandP2.randomize());
          DrivePort2.SHR(RandP2.Data1,RandP2.Shift_Operand2,1);
          assert(RandP2.randomize());
          DrivePort2.Add(RandP2.Data1,RandP2.Data2,1);
          end
          repeat(2) begin
          assert(RandP2.randomize());
          DrivePort2.SHL(RandP2.Data1,RandP2.Shift_Operand2,2);
          assert(RandP1.randomize());
          DrivePort2.Add(RandP2.Data1,RandP2.Data2,2);
          end
          repeat(2) begin
          assert(RandP2.randomize());
          DrivePort2.SHR(RandP2.Data1,RandP2.Shift_Operand2,3);
          assert(RandP2.randomize());
          DrivePort2.Add(RandP2.Data1,RandP2.Data2,3);
          end
        $write("%dns :End of Checking Send multiple commands from the same port with the same tags in Port2.\n",$time);
        end

        6:
        begin
        $write("%dns :Start Checking Submit multiple identical commands with different tags in Port2.\n",$time);

          repeat(4)begin
            assert (RandP2.randomize());
            DrivePort2.Add(50,22,RandP2.Tag); 
          end
        $write("%dns :Start Checking Submit multiple identical commands with different tags in Port2.\n",$time);
        end
    
      endcase

    end
  endtask
  task testP3(int testcase_number=1); // Test Case scenarios for Port3 with default test case number 1
    begin

      case(testcase_number)
        1: // Add and sub Testcases
        begin
          //Test cases for Add
          $write("%dns :Start Checking Add/Sub commands in Port3.\n",$time);

          DrivePort3.Add(50,22,0); // Simple Add test
          DrivePort3.Add(50,0, 1); // One operand is zero
          DrivePort3.Add(0,22, 2); // One operand is zero
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
          DrivePort3.Sub(0,22, 0); // One Operand is zero
          DrivePort3.Sub(0, 0, 1); // two Operands is zero
          DrivePort3.Sub(50,50,2); // Two equal Operands in Sub 
          DrivePort3.Sub(50,51,3); // Make Underflow by 1
          //--------------------------------------------------------------------------------------------//

          //----! Make Some Add/Sub commands that sake to Over/UnderFlow  !-----//
          repeat(10)@(posedge GlobalPort.clk);
          DrivePort3.Add('hEFFFFFEF,'h10000011,0);
          DrivePort3.Sub(0,1,1);
          DrivePort3.Add('hFFFFFFFF,3,2);
          DrivePort3.Sub('hFFFFFFFC,'hFFFFFFFE,3);

          $write("%dns :End of Checking Add/Sub in Port3.\n",$time);
        end

        2:// Shift Testcases
        begin
          $write("%dns :Start Checking Shift Commands in Port3.\n",$time);

          DrivePort3.SHL('hFFFFFFFF,0,0);            // Make Zero Shift Left
          DrivePort3.SHL(1,32,1);                    // Make 32 Shift Left
          DrivePort3.SHR('hFFFFFFFF,0,2);            // Make Zero Shift Right
          DrivePort3.SHR('h10000000,32,3);           // Make 32 Shift Right
          repeat(10)@(posedge GlobalPort.clk);

          //--------------------! Check the shift command on the zero operand !---------//

          repeat(2) begin
          assert(RandP3.randomize());
          DrivePort3.SHL(0,RandP3.Shift_Operand2,RandP3.Tag);
          assert(RandP3.randomize());
          DrivePort3.SHR(0,RandP3.Shift_Operand2,RandP3.Tag);
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //-------! Check the shift command on the second operand and the ignored values !--------//
         
          DrivePort3.SHL('hFFFFFFF0,'hFFFFFFE2, 0);
          DrivePort3.SHL('hFFFFFFF0,'hFEFEFEE1, 1);
          DrivePort3.SHR('h0FFFFFFF,'hFFFFFFE2, 2);
          DrivePort3.SHR('h0FFFFFFF,'hFEFEFEE1, 3);

          $write("%dns :End of Checking Shift Commands in Port3.\n",$time);
        end

        3:
        begin
          $write("%dns :Start Checking the sequence and prioritize the execution of commands in Port3.\n",$time);
          //--------------! Make 3 Add/Sub and 1 Shift command at the end !-----------------------//
          repeat(3)begin
          assert(RandP3.randomize());
            RandP3.do_RandCase(100,50,50,0,0,0,0);
          end
          assert(RandP3.randomize());
          RandP3.do_RandCase(0,0,0,100,50,50,0);
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          // -----------! Make 4 Add/Sub or Shift Commands with random order !--------------------// 

          repeat(4)begin
            assert(RandP3.randomize());
            RandP3.do_RandCase(50,100,0,50,50,50,0);
          end
        $write("%dns :End of Checking the sequence and prioritize the execution of commands in Port3.\n",$time);
        end

        4:
        begin
        $write("%dns :Start Checking Test various schedules and unauthorized commands in Port3.\n",$time);
          //--------------! Make 8 Random Valid Command with Random Time interval !--------------// 
          repeat(8)begin
            assert(RandP3.randomize());
            RandP3.full_random_valid_command(0);
            repeat(RandP3.Commandi)@(posedge GlobalPort.clk);
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //---------------! Make 4 Random invalid Command !-----------------------------//
          
          repeat(4)begin
            assert(RandP3.randomize());
            RandP3.full_random_invalid_command(0);
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //---------------! Send a combination of valid and invalid commands !----------// 

          repeat(4)begin
            assert(RandP3.randomize());
            RandP3.full_random_valid_command(1);
            assert(RandP3.randomize());
            RandP3.full_random_invalid_command(0);
          end
        $write("%dns :End of Checking Test various schedules and unauthorized commands in Port3.\n",$time);

        end
        // 
        5:
        begin
        $write("%dns :Start Checking Send multiple commands from the same port with the same tags in Port3.\n",$time);

          //-------! Send multiple commands from the same port with the same tags !------//

          repeat(2) begin
          assert(RandP3.randomize());
          DrivePort3.SHL(RandP3.Data1,RandP3.Shift_Operand2,0);
          assert(RandP3.randomize());
          DrivePort3.Add(RandP3.Data1,RandP3.Data2,0);
          end
          repeat(2) begin
          assert(RandP3.randomize());
          DrivePort3.SHR(RandP3.Data1,RandP3.Shift_Operand2,1);
          assert(RandP3.randomize());
          DrivePort3.Add(RandP3.Data1,RandP3.Data2,1);
          end
          repeat(2) begin
          assert(RandP3.randomize());
          DrivePort3.SHL(RandP3.Data1,RandP3.Shift_Operand2,2);
          assert(RandP3.randomize());
          DrivePort3.Add(RandP3.Data1,RandP3.Data2,2);
          end
          repeat(2) begin
          assert(RandP3.randomize());
          DrivePort3.SHR(RandP3.Data1,RandP3.Shift_Operand2,3);
          assert(RandP3.randomize());
          DrivePort3.Add(RandP3.Data1,RandP3.Data2,3);
          end
        $write("%dns :End of Checking Send multiple commands from the same port with the same tags in Port3.\n",$time);
        end

        6:
        begin
        $write("%dns :Start Checking Submit multiple identical commands with different tags in Port3.\n",$time);

          repeat(4)begin
            assert (RandP3.randomize());
            DrivePort3.Add(50,22,RandP3.Tag); 
          end
        $write("%dns :Start Checking Submit multiple identical commands with different tags in Port3.\n",$time);
        end
    
      endcase

    end
  endtask
  task testP4(int testcase_number=1); // Test Case scenarios for Port4 with default test case number 1
    begin

      case(testcase_number)
        1: // Add and sub Testcases
        begin
          //Test cases for Add
          $write("%dns :Start Checking Add/Sub commands in Port4.\n",$time);

          DrivePort4.Add(50,22,0); // Simple Add test
          DrivePort4.Add(50,0, 1); // One operand is zero
          DrivePort4.Add(0,22, 2); // One operand is zero
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
          DrivePort4.Sub(0,22, 0); // One Operand is zero
          DrivePort4.Sub(0, 0, 1); // two Operands is zero
          DrivePort4.Sub(50,50,2); // Two equal Operands in Sub 
          DrivePort4.Sub(50,51,3); // Make Underflow by 1
          //--------------------------------------------------------------------------------------------//

          //----! Make Some Add/Sub commands that sake to Over/UnderFlow  !-----//
          repeat(10)@(posedge GlobalPort.clk);

          DrivePort4.Add('hEFFFFFEF,'h10000011,0);
          DrivePort4.Sub(0,1,1);
          DrivePort4.Add('hFFFFFFFF,3,2);
          DrivePort4.Sub('hFFFFFFFC,'hFFFFFFFE,3);

          $write("%dns :End of Checking Add/Sub in Port4.\n",$time);
        end

        2:// Shift Testcases
        begin
          $write("%dns :Start Checking Shift Commands in Port4.\n",$time);

          DrivePort4.SHL('hFFFFFFFF,0,0);            // Make Zero Shift Left
          DrivePort4.SHL(1,32,1);                    // Make 32 Shift Left
          DrivePort4.SHR('hFFFFFFFF,0,2);            // Make Zero Shift Right
          DrivePort4.SHR('h10000000,32,3);           // Make 32 Shift Right
          repeat(10)@(posedge GlobalPort.clk);

          //--------------------! Check the shift command on the zero operand !---------//

          repeat(2) begin
          assert(RandP4.randomize());
          DrivePort4.SHL(0,RandP4.Shift_Operand2,RandP4.Tag);
          assert(RandP4.randomize());
          DrivePort4.SHR(0,RandP4.Shift_Operand2,RandP4.Tag);
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //-------! Check the shift command on the second operand and the ignored values !--------//
         
          DrivePort4.SHL('hFFFFFFF0,'hFFFFFFE2, 0);
          DrivePort4.SHL('hFFFFFFF0,'hFEFEFEE1, 1);
          DrivePort4.SHR('h0FFFFFFF,'hFFFFFFE2, 2);
          DrivePort4.SHR('h0FFFFFFF,'hFEFEFEE1, 3);

          $write("%dns :End of Checking Shift Commands in Port4.\n",$time);
        end

        3:
        begin
          $write("%dns :Start Checking the sequence and prioritize the execution of commands in Port4.\n",$time);
          //--------------! Make 3 Add/Sub and 1 Shift command at the end !-----------------------//
          repeat(3)begin
          assert(RandP4.randomize());
            RandP4.do_RandCase(100,50,50,0,0,0,0);
          end
          assert(RandP4.randomize());
          RandP4.do_RandCase(0,0,0,100,50,50,0);
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          // -----------! Make 4 Add/Sub or Shift Commands with random order !--------------------// 

          repeat(4)begin
            assert(RandP4.randomize());
            RandP4.do_RandCase(50,100,0,50,50,50,0);
          end
        $write("%dns :End of Checking the sequence and prioritize the execution of commands in Port4.\n",$time);
        end

        4:
        begin
        $write("%dns :Start Checking Test various schedules and unauthorized commands in Port4.\n",$time);
          //--------------! Make 8 Random Valid Command with Random Time interval !--------------// 
          repeat(8)begin
            assert(RandP4.randomize());
            RandP4.full_random_valid_command(0);
            repeat(RandP4.Commandi)@(posedge GlobalPort.clk);
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //---------------! Make 4 Random invalid Command !-----------------------------//
          
          repeat(4)begin
            assert(RandP4.randomize());
            RandP4.full_random_invalid_command(0);
          end
          //--------------------------------------------------------------------------------------------//
          repeat(10)@(posedge GlobalPort.clk);

          //---------------! Send a combination of valid and invalid commands !----------// 

          repeat(4)begin
            assert(RandP4.randomize());
            RandP4.full_random_valid_command(1);
            assert(RandP4.randomize());
            RandP4.full_random_invalid_command(0);
          end
        $write("%dns :End of Checking Test various schedules and unauthorized commands in Port4.\n",$time);

        end
        // 
        5:
        begin
        $write("%dns :Start Checking Send multiple commands from the same port with the same tags in Port4.\n",$time);

          //-------! Send multiple commands from the same port with the same tags !------//

          repeat(2) begin
          assert(RandP4.randomize());
          DrivePort4.SHL(RandP4.Data1,RandP4.Shift_Operand2,0);
          assert(RandP4.randomize());
          DrivePort4.Add(RandP1.Data1,RandP4.Data2,0);
          end
          repeat(2) begin
          assert(RandP4.randomize());
          DrivePort4.SHR(RandP4.Data1,RandP4.Shift_Operand2,1);
          assert(RandP4.randomize());
          DrivePort4.Add(RandP4.Data1,RandP4.Data2,1);
          end
          repeat(2) begin
          assert(RandP4.randomize());
          DrivePort4.SHL(RandP4.Data1,RandP4.Shift_Operand2,2);
          assert(RandP1.randomize());
          DrivePort4.Add(RandP4.Data1,RandP4.Data2,2);
          end
          repeat(2) begin
          assert(RandP4.randomize());
          DrivePort4.SHR(RandP4.Data1,RandP4.Shift_Operand2,3);
          assert(RandP4.randomize());
          DrivePort4.Add(RandP4.Data1,RandP4.Data2,3);
          end
        $write("%dns :End of Checking Send multiple commands from the same port with the same tags in Port4.\n",$time);
        end

        6:
        begin
        $write("%dns :Start Checking Submit multiple identical commands with different tags in Port4.\n",$time);

          repeat(4)begin
            assert (RandP4.randomize());
            DrivePort4.Add(50,22,RandP4.Tag); 
          end
        $write("%dns :Start Checking Submit multiple identical commands with different tags in Port4.\n",$time);
        end
    
      endcase

    end
  endtask

  task Make_out_of_order_result (); // Make out of order Shift result in port 1
    $write("%dns : Make_out_of_order_result Test activated\n",$time);
    fork
      testP1(3);
      testP2();
      testP3();
      testP4();
    join
    repeat(10)@(posedge GlobalPort.clk);
    $write("%dns : Make_out_of_order_result Test deactivated\n",$time);
  endtask

  task Reset_Test(); // Test Scenarios for Reset
    IReset(0); // Reset enable lenght: 1 Clock 
    @(posedge GlobalPort.clk);
    GlobalPort.reset     = 0;
    DrivePort1.Add(50,22,1);
    repeat(3)@(posedge GlobalPort.clk);
    IReset(0); // Reset enable lenght: 1 Clock 
    @(posedge GlobalPort.clk);
    GlobalPort.reset     = 0;
    DrivePort1.Add(50,22,1);
    repeat(3)@(posedge GlobalPort.clk);
    IReset(1); // Reset enable lenght: 2 Clock 
    @(posedge GlobalPort.clk);
    GlobalPort.reset     = 0;
    DrivePort1.Add(50,22,1);
    repeat(3)@(posedge GlobalPort.clk);
    //Reset anoumnt in Spec 
    IReset(2); // Reset enable lenght: 3 Clock 
    @(posedge GlobalPort.clk);
    GlobalPort.reset     = 0;
    DrivePort1.Add(50,22,1);
    repeat(3)@(posedge GlobalPort.clk);
    //Reset anoumnt in Book
    IReset(6);// Reset enable lenght: 7 Clock 
    @(posedge GlobalPort.clk);
    GlobalPort.reset     = 0;
    DrivePort1.Add(50,22,1);
    repeat(5)@(posedge GlobalPort.clk);
  endtask 

//------------------------------------------------------------------------------------------------

endclass //Generator
