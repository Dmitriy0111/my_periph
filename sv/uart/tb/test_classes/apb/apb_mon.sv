/*
*  File            :   apb_mon.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is apb interface monitor 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef APB_MON__SV
`define APB_MON__SV

class apb_mon extends dvv_mon #(ctrl_trans);
    `OBJ_BEGIN( apb_mon )

    virtual apb_if  vif;

    apb_mth         mth;

    extern function new(string name = "", dvv_bc parent = null);

    extern task     build();
    extern task     run();
    
endclass : apb_mon

function apb_mon::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task apb_mon::build();
    if( !dvv_res_db#(virtual apb_if)::get_res_db("apb_if_0",vif) )
        $fatal();

    mth = apb_mth::create::create_obj("[ APB MON MTH ]", this);
    mth.vif = vif;

    $display("%s build complete", this.fname);
endtask : build

task apb_mon::run();
    forever
    begin
        mth.wait_clk();
        #0;
        if( mth.read_detect() )
        begin
            $display("WRITE_TR addr = 0x%h, data = 0x%h", mth.get_paddr(), mth.get_pwdata());
        end
        else if( mth.write_detect() )
        begin
            $display("READ_TR  addr = 0x%h, data = 0x%h", mth.get_paddr(), mth.get_prdata());
        end
    end
endtask : run

`endif // APB_MON__SV
