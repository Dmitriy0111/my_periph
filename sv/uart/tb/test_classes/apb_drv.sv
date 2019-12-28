/*
*  File            :   apb_drv.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.27
*  Language        :   SystemVerilog
*  Description     :   This is apb interface driver 
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef APB_DRV__SV
`define APB_DRV__SV

class apb_drv extends dvv_drv #(sif_trans);

    `OBJ_BEGIN( apb_drv )

    virtual apb_if      vif;

    sif_trans           sif_item;

    uart_struct         h_uart = new_uart( 0 );

    extern function new(string name = "", dvv_bc parent = null);

    extern task     set_paddr   (    logic [31 : 0] val);
    extern task     get_paddr   (ref logic [31 : 0] val);
    extern task     get_prdata  (ref logic [31 : 0] val);
    extern task     set_pwdata  (    logic [31 : 0] val);
    extern task     get_pwdata  (ref logic [31 : 0] val);
    extern task     set_psel    (    logic [0  : 0] val);
    extern task     get_psel    (ref logic [0  : 0] val);
    extern task     set_penable (    logic [0  : 0] val);
    extern task     get_penable (ref logic [0  : 0] val);
    extern task     set_pwrite  (    logic [0  : 0] val);
    extern task     get_pwrite  (ref logic [0  : 0] val);
    extern task     get_pready  (ref logic [0  : 0] val);
    extern task     get_pslverr (ref logic [0  : 0] val);

    extern task     wait_clk();

    extern task     write_reg(logic [31 : 0] w_addr, logic [31 : 0] w_data);
    extern task     read_reg(logic [31 : 0] r_addr, output logic [31 : 0] r_data);

    extern task     build();
    extern task     run();
    
endclass : apb_drv

function apb_drv::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task apb_drv::set_paddr(logic [31 : 0] val);
    vif.paddr = val;
endtask : set_paddr

task apb_drv::get_paddr(ref logic [31 : 0] val);
    val = vif.paddr;
endtask : get_paddr

task apb_drv::get_prdata(ref logic [31 : 0] val);
    val = vif.prdata;
endtask : get_prdata

task apb_drv::set_pwdata(    logic [31 : 0] val);
    vif.pwdata = val;
endtask : set_pwdata

task apb_drv::get_pwdata(ref logic [31 : 0] val);
    val = vif.pwdata;
endtask : get_pwdata

task apb_drv::set_psel(    logic [0  : 0] val);
    vif.psel = val;
endtask : set_psel

task apb_drv::get_psel(ref logic [0  : 0] val);
    val = vif.psel;
endtask : get_psel

task apb_drv::set_penable(    logic [0  : 0] val);
    vif.penable = val;
endtask : set_penable

task apb_drv::get_penable(ref logic [0  : 0] val);
    val = vif.penable;
endtask : get_penable

task apb_drv::set_pwrite(    logic [0  : 0] val);
    vif.pwrite = val;
endtask : set_pwrite

task apb_drv::get_pwrite(ref logic [0  : 0] val);
    val = vif.pwrite;
endtask : get_pwrite

task apb_drv::get_pready(ref logic [0  : 0] val);
    val = vif.pready;
endtask : get_pready

task apb_drv::get_pslverr(ref logic [0  : 0] val);
    val = vif.pslverr;
endtask : get_pslverr


task apb_drv::wait_clk();
    @(posedge vif.pclk);
endtask : wait_clk

task apb_drv::build();
    if( !dvv_res_db#(virtual apb_if)::get_res_db("apb_if_0",vif) )
        $fatal();
    sif_item = sif_trans::create::create_obj("sif_item", this);
    item_sock = new();
    $display("%s build complete", this.name);
endtask : build

task apb_drv::write_reg(logic [31 : 0] w_addr, logic [31 : 0] w_data);
    this.set_paddr(w_addr);
    this.set_pwdata(w_data);
    this.set_psel('1);
    this.set_pwrite('1);
    this.wait_clk();
    this.set_penable('1);
    for(;;)
    begin
        this.wait_clk();
        if( vif.pready )
            break;
    end
    this.set_psel('0);
    this.set_pwrite('0);
    this.set_penable('0);
endtask : write_reg

task apb_drv::read_reg(logic [31 : 0] r_addr, output logic [31 : 0] r_data);
    this.set_paddr(r_addr);
    this.set_psel('1);
    this.set_pwrite('0);
    this.wait_clk();
    this.set_penable('1);
    for(;;)
    begin
        this.wait_clk();
        if( vif.pready )
            break;
    end
    this.set_psel('0);
    this.set_pwrite('0);
    this.set_penable('0);
    r_data = vif.prdata;
endtask : read_reg

task apb_drv::run();
    @(posedge vif.presetn);

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

`endif // APB_DRV__SV
