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

    apb_mth                     mth;

    dvv_aep #(logic [15 : 0])   u_mon_aep;

    uart_struct                 h_uart = new_uart( 0 , 0 );

    extern function new(string name = "", dvv_bc parent = null);

    extern task     write_reg(logic [31 : 0] w_addr, logic [31 : 0] w_data);
    extern task     read_reg(logic [31 : 0] r_addr, output logic [31 : 0] r_data);

    extern task     build();
    extern task     run();
    
endclass : apb_drv

function apb_drv::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
    u_mon_aep = new();
endfunction : new

task apb_drv::build();
    if( !dvv_res_db#(virtual apb_if)::get_res_db("apb_if_0",vif) )
        $fatal();

    mth = apb_mth::create::create_obj("[ APB DRV MTH ]", this);
    mth.vif = vif;

    item = ctrl_trans::create::create_obj("[ APB ITEM ]", this);
    item_sock = new();

    $display("%s build complete", this.fname);
endtask : build

task apb_drv::write_reg(logic [31 : 0] w_addr, logic [31 : 0] w_data);
    mth.set_paddr(w_addr);
    mth.set_pwdata(w_data);
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

task apb_drv::read_reg(logic [31 : 0] r_addr, output logic [31 : 0] r_data);
    mth.set_paddr(r_addr);
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
    r_data = mth.get_prdata();
endtask : read_reg

task apb_drv::run();
    mth.wait_reset();

    h_uart.cr_c.data.rx_fifo_lvl = '0;
    h_uart.cr_c.data.tx_fifo_lvl = '0;
    h_uart.cr_c.data.rec_en      = '0;
    h_uart.cr_c.data.tr_en       = '1;

    write_reg(h_uart.cr_c.addr, h_uart.cr_c.data);

    item_sock.trig_sock();
    forever
    begin
        item_sock.rec_msg(item);
        
        h_uart.tx_rx_c.data = item.data;
        h_uart.dfr_c.data = item.freq;

        write_reg(h_uart.dfr_c.addr, h_uart.dfr_c.data);

        u_mon_aep.write(h_uart.dfr_c.data);
        
        write_reg(h_uart.tx_rx_c.addr, h_uart.tx_rx_c.data);

        for(;;)
        begin
            read_reg(h_uart.cr_c.addr, h_uart.cr_c.data);
            if( h_uart.cr_c.data.tx_full == 0 )
                break;
        end

        item_sock.trig_sock();
    end
endtask : run

`endif // APB_DRV__SV
