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

class avalon_drv extends base_ctrl_drv;
    `OBJ_BEGIN( avalon_drv )

    virtual avalon_if           vif;

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

    mth = avalon_mth::create::create_obj("avalon_drv_mth", this);
    mth.vif = vif;

    item = new("avalon_drv_item", this);
    resp_item = new("avalon_drv_resp_item", this);

    item_sock = new();
    resp_sock = new();
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
    fork
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
    join_none
endtask : run

`endif // AVALON_DRV__SV
