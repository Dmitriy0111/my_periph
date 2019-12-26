/*
*  File            :   sif_drv.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is simple interface driver 
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef SIF_DRV__SV
`define SIF_DRV__SV

class sif_drv extends dvv_drv #(sif_trans);

    `OBJ_BEGIN( sif_drv )

    virtual simple_if   vif;

    sif_trans           sif_item;

    uart_struct         h_uart = new_uart( 0 );

    extern function new(string name = "", dvv_bc parent = null);
    extern task     set_addr(    logic [31 : 0] val);
    extern task     get_addr(ref logic [31 : 0] val);
    extern task     set_re(    logic [0  : 0] val);
    extern task     get_re(ref logic [0  : 0] val);
    extern task     set_we(    logic [0  : 0] val);
    extern task     get_we(ref logic [0  : 0] val);
    extern task     set_wd(    logic [31 : 0] val);
    extern task     get_wd(ref logic [31 : 0] val);
    extern task     get_rd(ref logic [31 : 0] val);
    extern task     wait_clk();
    extern task     reset_signals();

    extern task     write_reg(logic [31 : 0] w_addr, logic [31 : 0] w_data);
    extern task     read_reg(logic [31 : 0] r_addr, output logic [31 : 0] r_data);

    extern task     build();
    extern task     run();
    
endclass : sif_drv

function sif_drv::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task sif_drv::set_addr(logic [31 : 0] val);
    vif.addr = val;
endtask : set_addr

task sif_drv::get_addr(ref logic [31 : 0] val);
    val = vif.addr;
endtask : get_addr

task sif_drv::set_re(logic [0  : 0] val);
    vif.re = val;
endtask : set_re

task sif_drv::get_re(ref logic [0  : 0] val);
    val = vif.re;
endtask : get_re

task sif_drv::set_we(logic [0  : 0] val);
    vif.we = val;
endtask : set_we

task sif_drv::get_we(ref logic [0  : 0] val);
    val = vif.we;
endtask : get_we

task sif_drv::set_wd(logic [31 : 0] val);
    vif.wd = val;
endtask : set_wd

task sif_drv::get_wd(ref logic [31 : 0] val);
    val = vif.wd;
endtask : get_wd

task sif_drv::get_rd(ref logic [31 : 0] val);
    val = vif.rd;
endtask : get_rd

task sif_drv::wait_clk();
    @(posedge vif.clk);
endtask : wait_clk

task sif_drv::reset_signals();
    vif.addr = '0;
    vif.we = '0;
    vif.re = '0;
    vif.wd = '0;
endtask : reset_signals

task sif_drv::build();
    if( !dvv_res_db#(virtual simple_if)::get_res_db("sif_0",vif) )
        $fatal();
    sif_item = sif_trans::create::create_obj("sif_item", this);
    item_sock = new();
    $display("%s build complete", this.name);
endtask : build

task sif_drv::write_reg(logic [31 : 0] w_addr, logic [31 : 0] w_data);
    this.set_addr(w_addr);
    this.set_wd(w_data);
    this.set_we('1);
    this.set_re('0);
    this.wait_clk();
    this.set_we('0);
endtask : write_reg

task sif_drv::read_reg(logic [31 : 0] r_addr, output logic [31 : 0] r_data);
    this.set_addr(r_addr);
    this.set_we('0);
    this.set_re('1);
    this.wait_clk();
    this.set_re('0);
    r_data = vif.rd;
endtask : read_reg

task sif_drv::run();
    @(posedge vif.rstn);

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
        item_sock.rec_msg(sif_item);
        h_uart.tx_rx_c.data = sif_item.data;
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
