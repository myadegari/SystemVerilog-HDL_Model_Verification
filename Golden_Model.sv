`include "sv_Interfaces.sv"

class  Golden_Model;

function int GModel_result (input int data1,data2,cmd);
    if(cmd = 1)begin
        GModel_result = data1+data2;
        if(GModel_result > 32{1'b1})
            GModel_result = 0;
    end
    
endfunction


endclass