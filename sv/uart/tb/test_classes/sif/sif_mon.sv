/*
*  File            :   sif_mon.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is simple interface monitor 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef SIF_MON__SV
`define SIF_MON__SV

class sif_mon extends dvv_mon #(ctrl_trans);
    `OBJ_BEGIN( sif_mon )

    virtual simple_if   vif;

    sif_mth             mth;

    extern function new(string name = "", dvv_bc parent = null);

    extern task     build();
    extern task     run();
    
endclass : sif_mon

function sif_mon::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task sif_mon::build();
    if( !dvv_res_db#(virtual simple_if)::get_res_db("sif_0",vif) )
        $fatal();

    mth = sif_mth::create::create_obj("[ SIF MON MTH ]", this);
    mth.vif = vif;
        
    $display("%s build complete", this.fname);
endtask : build

task sif_mon::run();
    forever
    begin
        mth.wait_clk();
        #0;
        if( mth.get_we() )
        begin
            $display("WRITE_TR addr = 0x%h, data = 0x%h", mth.get_addr(), mth.get_wd());
        end
        else if( mth.get_re() )
        begin
            $display("READ_TR  addr = 0x%h, data = 0x%h", mth.get_addr(), mth.get_rd());
        end
    end
endtask : run

`endif // SIF_MON__SV
