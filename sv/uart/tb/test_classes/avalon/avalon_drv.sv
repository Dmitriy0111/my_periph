/*
*  File            :   avalon_drv.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.09
*  Language        :   SystemVerilog
*  Description     :   This is avalon interface driver 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef AVALON_DRV__SV
`define AVALON_DRV__SV

class avalon_drv extends dvv_drv #(ctrl_trans);
    `OBJ_BEGIN( avalon_drv )

    virtual avalon_if           vif;

    ctrl_trans                  item;
    ctrl_trans                  resp_item;

    avalon_mth                  mth;

    extern function new(string name = "", dvv_bc parent = null);

    extern task write_reg();
    extern task read_reg();

    extern task build();
    extern task run();
    
endclass : avalon_drv

function avalon_drv::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task avalon_drv::build();
    if( !dvv_res_db#(virtual avalon_if)::get_res_db("avalon_if_0",vif) )
        $fatal();

    mth = avalon_mth::create::create_obj("[ AVALON DRV MTH ]", this);
    mth.vif = vif;

    item = ctrl_trans::create::create_obj("[ AVALON DRV ITEM ]", this);
    resp_item = ctrl_trans::create::create_obj("[ AVALON DRV RESP ITEM ]", this);

    item_sock = new();
    resp_sock = new();

    $display("%s build complete", this.fname);
endtask : build

task avalon_drv::write_reg();
    mth.set_address(item.get_addr());
    mth.set_writedata(item.get_data());
    mth.set_chipselect('1);
    mth.set_write('1);
    mth.wait_clk();
    mth.set_chipselect('0);
    mth.set_write('0);
endtask : write_reg

task avalon_drv::read_reg();
    mth.set_address(item.get_addr());
    mth.set_chipselect('1);
    mth.set_write('0);
    mth.wait_clk();
    mth.set_chipselect('0);
    mth.wait_clk();
    mth.set_write('0);
    resp_item.data = mth.get_readdata();
    resp_sock.send_msg(resp_item);
endtask : read_reg

task avalon_drv::run();
    forever
    begin
        item_sock.rec_msg(item);
        item.set_addr(item.get_addr()>>2);

        if( item.get_we_re() )
            write_reg();
        else
            read_reg();
        item_sock.trig_sock();
    end
endtask : run

`endif // AVALON_DRV__SV
