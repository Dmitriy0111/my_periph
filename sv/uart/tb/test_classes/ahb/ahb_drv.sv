/*
*  File            :   ahb_drv.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.09
*  Language        :   SystemVerilog
*  Description     :   This is ahb interface driver 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef AHB_DRV__SV
`define AHB_DRV__SV

class ahb_drv extends dvv_drv #(ctrl_trans);
    `OBJ_BEGIN( ahb_drv )

    virtual ahb_if      vif;
    ahb_mth             mth;

    ctrl_trans          item;

    uart_struct         h_uart = new_uart( 0 , 0 );

    extern function new(string name = "", dvv_bc parent = null);

    extern task     write_reg(logic [31 : 0] w_addr, logic [31 : 0] w_data);
    extern task     read_reg(logic [31 : 0] r_addr, output logic [31 : 0] r_data);

    extern task     build();
    extern task     run();
    
endclass : ahb_drv

function ahb_drv::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task ahb_drv::build();
    if( !dvv_res_db#(virtual ahb_if)::get_res_db("ahb_if_0",vif) )
        $fatal();

    mth = ahb_mth::create::create_obj("[ AHB DRV MTH ]", this);
    mth.vif = vif;

    item = ctrl_trans::create::create_obj("[ AHB ITEM ]", this);
    item_sock = new();

    $display("%s build complete", this.fname);
endtask : build

task ahb_drv::write_reg(logic [31 : 0] w_addr, logic [31 : 0] w_data);
    mth.set_haddr(w_addr);
    mth.set_hwdata(w_data);
    mth.set_hsel('1);
    mth.set_hwrite('1);
    mth.set_hsize(3'b011);
    mth.set_hburst(3'b000);
    mth.set_htrans(2'b10);
    mth.wait_clk();
    mth.set_hsel('0);
    mth.set_hwrite('0);
    for(;;)
    begin
        mth.wait_clk();
        if( mth.get_hready() )
            break;
    end
endtask : write_reg

task ahb_drv::read_reg(logic [31 : 0] r_addr, output logic [31 : 0] r_data);
    mth.set_haddr(r_addr);
    mth.set_hsel('1);
    mth.set_hwrite('0);
    mth.set_hsize(3'b011);
    mth.set_hburst(3'b000);
    mth.set_htrans(2'b10);
    mth.wait_clk();
    mth.set_hsel('0);
    mth.set_hwrite('0);
    for(;;)
    begin
        mth.wait_clk();
        if( mth.get_hready() )
            break;
    end
    r_data = mth.get_hrdata();
endtask : read_reg

task ahb_drv::run();
    mth.wait_reset();

    h_uart.dfr_c.data = 40;

    h_uart.cr_c.data.rx_fifo_lvl = '0;
    h_uart.cr_c.data.tx_fifo_lvl = '0;
    h_uart.cr_c.data.rec_en      = '0;
    h_uart.cr_c.data.tr_en       = '1;

    write_reg(h_uart.cr_c.addr, h_uart.cr_c.data);
    write_reg(h_uart.dfr_c.addr, h_uart.dfr_c.data);

    item_sock.trig_sock();
    forever
    begin
        item_sock.rec_msg(item);
        h_uart.tx_rx_c.data = item.data;
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

`endif // AHB_DRV__SV
