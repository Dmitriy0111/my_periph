/*
*  File            :   apb_drv.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.27
*  Language        :   SystemVerilog
*  Description     :   This is apb interface driver 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef APB_DRV__SV
`define APB_DRV__SV

class apb_drv extends dvv_drv #(ctrl_trans);
    `OBJ_BEGIN( apb_drv )

    virtual apb_if              vif;

    ctrl_trans                  item;
    ctrl_trans                  resp_item;

    apb_mth                     mth;

    extern function new(string name = "", dvv_bc parent = null);

    extern task write_reg();
    extern task read_reg();

    extern task build();
    extern task run();
    
endclass : apb_drv

function apb_drv::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task apb_drv::build();
    if( !dvv_res_db#(virtual apb_if)::get_res_db("apb_if_0",vif) )
        $fatal();

    mth = apb_mth::create::create_obj("[ APB DRV MTH ]", this);
    mth.vif = vif;

    item = ctrl_trans::create::create_obj("[ APB ITEM ]", this);
    resp_item = ctrl_trans::create::create_obj("[ APB DRV RESP ITEM ]", this);

    item_sock = new();
    resp_sock = new();

    $display("%s build complete", this.fname);
endtask : build

task apb_drv::write_reg();
    mth.set_paddr(item.get_addr());
    mth.set_pwdata(item.get_data());
    mth.set_psel('1);
    mth.set_pwrite('1);
    mth.wait_clk();
    mth.set_penable('1);
    for(;;)
    begin
        mth.wait_clk();
        if( mth.get_pready() )
            break;
    end
    mth.set_psel('0);
    mth.set_pwrite('0);
    mth.set_penable('0);
endtask : write_reg

task apb_drv::read_reg();
    mth.set_paddr(item.get_addr());
    mth.set_psel('1);
    mth.set_pwrite('0);
    mth.wait_clk();
    mth.set_penable('1);
    for(;;)
    begin
        mth.wait_clk();
        if( mth.get_pready() )
            break;
    end
    mth.set_psel('0);
    mth.set_pwrite('0);
    mth.set_penable('0); 
    resp_item.data = mth.get_prdata();
    resp_sock.send_msg(resp_item);
endtask : read_reg

task apb_drv::run();
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

`endif // APB_DRV__SV
