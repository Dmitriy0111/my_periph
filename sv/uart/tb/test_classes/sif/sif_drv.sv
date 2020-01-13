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
    virtual irq_if              irq_vif;

    ctrl_trans                  item;

    sif_mth                     mth;

    dvv_aep #(logic [15 : 0])   u_mon_aep;

    uart_struct                 h_uart = new_uart( 0 , 0 );

    extern function new(string name = "", dvv_bc parent = null);

    extern task     write_reg(logic [31 : 0] w_addr, logic [31 : 0] w_data);
    extern task     read_reg(logic [31 : 0] r_addr, output logic [31 : 0] r_data);

    extern task     build();
    extern task     run();
    
endclass : sif_drv

function sif_drv::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
    u_mon_aep = new();
endfunction : new

task sif_drv::build();
    if( !dvv_res_db#(virtual simple_if)::get_res_db("sif_if_0",ctrl_vif) )
        $fatal();

    if( !dvv_res_db#(virtual irq_if)::get_res_db("irq_if_0",irq_vif) )
        $fatal();

    mth = sif_mth::create::create_obj("[ SIF DRV MTH ]", this);
    mth.ctrl_vif = ctrl_vif;

    item = ctrl_trans::create::create_obj("[ SIF ITEM ]", this);
    item_sock = new();

    $display("%s build complete", this.fname);
endtask : build

task sif_drv::write_reg(logic [31 : 0] w_addr, logic [31 : 0] w_data);
    mth.set_addr(w_addr);
    mth.set_wd(w_data);
    mth.set_we('1);
    mth.set_re('0);
    mth.wait_clk();
    mth.set_we('0);
endtask : write_reg

task sif_drv::read_reg(logic [31 : 0] r_addr, output logic [31 : 0] r_data);
    mth.set_addr(r_addr);
    mth.set_we('0);
    mth.set_re('1);
    mth.wait_clk();
    mth.set_re('0);
    r_data = mth.get_rd();
endtask : read_reg

task sif_drv::run();
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

`endif // SIF_DRV__SV
