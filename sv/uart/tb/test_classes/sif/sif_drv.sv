/*
*  File            :   sif_drv.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is simple interface driver 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef SIF_DRV__SV
`define SIF_DRV__SV

class sif_drv extends dvv_drv #(ctrl_trans);
    `OBJ_BEGIN( sif_drv )

    virtual simple_if           ctrl_vif;

    ctrl_trans                  item;
    ctrl_trans                  resp_item;

    sif_mth                     mth;

    extern function new(string name = "", dvv_bc parent = null);

    extern task write_reg();
    extern task read_reg();

    extern task build();
    extern task run();
    
endclass : sif_drv

function sif_drv::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task sif_drv::build();
    if( !dvv_res_db#(virtual simple_if)::get_res_db("sif_if_0",ctrl_vif) )
        $fatal();

    mth = sif_mth::create::create_obj("[ SIF DRV MTH ]", this);
    mth.ctrl_vif = ctrl_vif;

    item = ctrl_trans::create::create_obj("[ SIF DRV ITEM ]", this);
    resp_item = ctrl_trans::create::create_obj("[ SIF DRV RESP ITEM ]", this);

    item_sock = new();
    resp_sock = new();
endtask : build

task sif_drv::write_reg();
    mth.set_addr(item.get_addr());
    mth.set_wd(item.get_data());
    mth.set_we('1);
    mth.set_re('0);
    mth.wait_clk();
    mth.set_we('0);
endtask : write_reg

task sif_drv::read_reg();
    mth.set_addr(item.get_addr());
    mth.set_we('0);
    mth.set_re('1);
    mth.wait_clk();
    mth.set_re('0);
    resp_item.data = mth.get_rd();
    resp_sock.send_msg(resp_item);
endtask : read_reg

task sif_drv::run();
    forever
    begin
        item_sock.rec_msg(item);

        if( item.get_we_re() )
            write_reg();
        else
            read_reg();
        item_sock.trig_sock();
    end
endtask : run

`endif // SIF_DRV__SV
