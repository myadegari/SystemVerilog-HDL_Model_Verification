`include "sv_Interfaces.sv"

class make_random;
    
    //Generate two random numbers whose sum is exactly equal to 'hFFFFFFFF
    rand bit [31:0] Inputs[2];
    constraint C02 { Inputs.sum () == 'hFFFFFFFF;} 
    
    //Generate two random numbers whose addition causes exactly to overflow by 1
    rand bit [32:0] Inputs2[2];
    constraint C03 { Inputs2.sum () == 'h100000000;}
    
    /* Define random values for commands, tags and data
        The "i" at the end of Command and in CMD indicates the possibility of duplication of these values.
    */
    randc   bit  [3:0]  Command;
    rand    bit  [3:0]  Commandi;
    randc   bit  [3:0]  invCMD;
    rand    bit  [3:0]  invCMDi;
    randc   bit  [1:0]  Tag;
    rand    bit  [31:0] Data1;
    rand    bit  [31:0] Data2;
    /*
        test_selector is a random value for select tests in Random_Test_Selector Task
        case_selector is a random value for select testcase in Random_Test_Selector Task in selected Test
        --------------------------------------------------------------------------------------------------
        Shift_Operand2 Make random Valid for shift
    */
    randc   bit  [2:0]  test_selector;
    rand    bit  [2:0]  Case_selector;
    rand    bit  [4:0]  Shift_Operand2;

    /* 
    ----------------------------------------------------------------------------------------------
    Define Constraint: in Command and Commandi Equal weight distribution between Add / sub and Shift commands
                       in Data maked them less than 'hFFFFFFFF
                       in invCMD maked select invalid Command 
    -----------------------------------------------------------------------------------------------------
    */
    constraint C01{ Command dist{[1:2]:/1,[5:6]:/1};
                    Commandi dist{[1:2]:/1,[5:6]:/1};
                    Data1 < 'hFFFFFFFF;
                    Data2 < 'hFFFFFFFF;
                    !(invCMD inside {0,1,2,5,6});
                    !(invCMDi inside {0,1,2,5,6});
                    !(test_selector inside{7});
                    !(Case_selector inside{7}) ;}
    

    int portNumber;
    virtual Port_Stimuli SPort;
    virtual Port_Global GlobalPort;


    function new (int _portNumber, virtual Port_Global _GlobalPort, virtual Port_Stimuli _SPort);
        begin
            this.SPort      = _SPort;
            this.GlobalPort = _GlobalPort;
        end
    endfunction
    /*
    ------------------------------------------------------------------------------------
    Maked Fully Random Valid command with option that makes iterative command or not
    option --> 1 Build non-duplicate commands
    option --> 0 uild iterative commands
    ------------------------------------------------------------------------------------
    */
    task full_random_valid_command(int option=1);
        begin
        if (option == 1)
        SPort.req_cmd_in = Command;
        else
        SPort.req_cmd_in = Commandi;

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
    /*
    ------------------------------------------------------------------------------------
    Maked Fully Random Invalid command with option that makes iterative command or not
    option --> 1 Build non-duplicate commands
    option --> 0 uild iterative commands
    ------------------------------------------------------------------------------------
    */
    task full_random_invalid_command(int option=1);
        begin
        if (option == 1)
        SPort.req_cmd_in = invCMD;
        else
        SPort.req_cmd_in = invCMDi;
        
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
    /*
    ------------------------------------------------------------------------------------
    Build random commands with varying probabilities between command types
    In such a way that the
        * First input is the possibility of Add/Sub 
            ** Second input is the possibility of Add 
            ** Third input is the possibility of Sub 
        *****************************************************
        * Fourth input is the possibility of Shift
            ** Fifth input is the possibility of Shift_Left
            ** Sixth input is the possibility of Shift_Right
        *****************************************************
        * Seventh input is the possibility of Invalid Commands
    ------------------------------------------------------------------------------------
    */
    
    task do_RandCase(int AddSub_Chance,int Add_Chance, int Sub_Chance,
                     int SH_Chance, int SHL_Chance, int SHR_Chance, int INV_chance);
        begin
            randcase
                AddSub_Chance:begin
                                    randcase
                                        Add_Chance:begin
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
                                        Sub_Chance:begin
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
                                    endcase
                              end

                SH_Chance:begin
                                randcase
                                    SHL_Chance:begin
                                        SPort.req_cmd_in = 4'b0101;
                                        SPort.req_data_in = Data1;
                                        SPort.req_tag_in = Tag;
                                        @(posedge GlobalPort.clk);
                                        SPort.req_cmd_in = 0;
                                        SPort.req_data_in = Data2;
                                        SPort.req_tag_in = 0;
                                        @(posedge GlobalPort.clk);
                                        SPort.req_data_in = 0;
                                                end
                                    SHR_Chance:begin
                                        SPort.req_cmd_in = 4'b0110;
                                        SPort.req_data_in = Data1;
                                        SPort.req_tag_in = Tag;
                                        @(posedge GlobalPort.clk);
                                        SPort.req_cmd_in = 0;
                                        SPort.req_data_in = Data2;
                                        SPort.req_tag_in = 0;
                                        @(posedge GlobalPort.clk);
                                        SPort.req_data_in = 0;
                                                end
                                endcase
                          end
                INV_chance:begin
                                SPort.req_cmd_in = invCMD;
                                SPort.req_data_in = Data1;
                                SPort.req_tag_in = Tag;
                                @(posedge GlobalPort.clk);
                                SPort.req_cmd_in = 0;
                                SPort.req_data_in = Data2;
                                SPort.req_tag_in = 0;
                                @(posedge GlobalPort.clk);
                                SPort.req_data_in = 0;
                            end
            endcase
    end
    endtask

endclass