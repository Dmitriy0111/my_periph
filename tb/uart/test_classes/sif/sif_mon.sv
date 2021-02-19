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

class sif_mon extends base_ctrl_mon;
    `OBJ_BEGIN( sif_mon )

    virtual simple_if       ctrl_vif;

    sif_mth                 mth;

    dvv_aep #(ctrl_trans)   cov_aep;

    extern function new(string name = "", dvv_bc parent = null);

    extern task build();
    extern task run();

    extern task pars_we();
    extern task pars_re();
    
endclass : sif_mon

function sif_mon::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
    cov_aep = new("cov_aep");
endfunction : new

task sif_mon::build();
    if( !dvv_res_db#(virtual simple_if)::get_res_db("sif_if_0",ctrl_vif) )
        $fatal();

    mth = sif_mth::create::create_obj("sif_mon_mth", this);
    mth.ctrl_vif = ctrl_vif;

    item = new("sif_item", this);
endtask : build

task sif_mon::run();
    fork
        this.pars_we();
        this.pars_re();
    join_none
endtask : run

task sif_mon::pars_we();
    forever
    begin
        wait( mth.ctrl_vif.we == 1'b1 );
        mth.wait_clk();
        item.set_data(mth.get_wd());
        item.set_addr(mth.get_addr());
        item.set_we_re(1'b1);
        cov_aep.write(item);
        $swrite(msg,"WRITE_TR addr = 0x%h, data = 0x%h at time %tns\n", mth.get_addr(), mth.get_wd(), $time());
        print(msg);
    end
endtask : pars_we

task sif_mon::pars_re();
    forever
    begin
        wait( mth.ctrl_vif.re == 1'b1 );
        mth.wait_clk();
        item.set_data(mth.get_wd());
        item.set_addr(mth.get_addr());
        item.set_we_re(1'b0);
        cov_aep.write(item);
        $swrite(msg,"READ_TR  addr = 0x%h, data = 0x%h at time %tns\n", mth.get_addr(), mth.get_rd(), $time());
        print(msg);
    end
endtask : pars_re

`endif // SIF_MON__SV
