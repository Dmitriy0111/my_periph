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

    virtual simple_if   ctrl_vif;

    sif_mth             mth;

    ctrl_trans          item;

    dvv_aep #(ctrl_trans)   cov_aep;

    extern function new(string name = "", dvv_bc parent = null);

    extern task     build();
    extern task     run();
    
endclass : sif_mon

function sif_mon::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
    cov_aep = new();
endfunction : new

task sif_mon::build();
    if( !dvv_res_db#(virtual simple_if)::get_res_db("sif_if_0",ctrl_vif) )
        $fatal();

    mth = sif_mth::create::create_obj("[ SIF MON MTH ]", this);
    mth.ctrl_vif = ctrl_vif;

    item = ctrl_trans::create::create_obj("[ SIF ITEM ]", this);
        
    $display("%s build complete", this.fname);
endtask : build

task sif_mon::run();
    forever
    begin
        mth.wait_clk();
        #0;
        if( mth.get_we() )
        begin
            item.set_data(mth.get_wd());
            item.set_addr(mth.get_addr());
            item.set_we_re(mth.get_we());
            cov_aep.write(item);
            $display("WRITE_TR addr = 0x%h, data = 0x%h", mth.get_addr(), mth.get_wd());
        end
        if( mth.get_re() )
        begin
            item.set_data(mth.get_wd());
            item.set_addr(mth.get_addr());
            item.set_we_re(mth.get_re());
            cov_aep.write(item);
            $display("READ_TR  addr = 0x%h, data = 0x%h", mth.get_addr(), mth.get_rd());
        end
    end
endtask : run

`endif // SIF_MON__SV
