/*
*  File            :   uart_drv.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.13
*  Language        :   SystemVerilog
*  Description     :   This is uart interface driver 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef UART_DRV__SV
`define UART_DRV__SV

class uart_drv extends dvv_drv #(ctrl_trans);
    `OBJ_BEGIN( uart_drv )

    typedef uart_drv drv_t;

    logic   [15 : 0]                    dfr = 40;

    dvv_ap  #(logic [15 : 0], drv_t)    drv_ap;

    virtual uart_if                     vif;

    ctrl_trans                          item;

    extern function new(string name = "", dvv_bc parent = null);

    extern task wait_clk();

    extern task build();
    extern task run();

    extern task drv_rx();

    extern function void write(logic [15 : 0] item);
    
endclass : uart_drv

function uart_drv::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
    drv_ap = new(this);
endfunction : new

task uart_drv::wait_clk();
    @(posedge vif.clk);
endtask : wait_clk

task uart_drv::build();
    if( !dvv_res_db#(virtual uart_if)::get_res_db("uif_0",vif) )
        $fatal();

    item = ctrl_trans::create::create_obj("[ UART DRV ITEM ]", this);

    item_sock = new();
endtask : build

task uart_drv::run();
    fork
        this.drv_rx();
    join_none
endtask : run

task uart_drv::drv_rx();
    logic   [7 : 0]     send_data;
    vif.uart_rx = '1;
    forever
    begin
        item_sock.rec_msg(item);

        send_data = item.data;

        vif.uart_rx = '0;
        repeat(this.dfr) this.wait_clk();

        repeat(8)
        begin
            vif.uart_rx = send_data[0];
            send_data = send_data >> 1;
            repeat(this.dfr) this.wait_clk();
        end

        vif.uart_rx = '1;
        repeat(this.dfr) this.wait_clk();
    end
endtask : drv_rx

function void uart_drv::write(logic [15 : 0] item);
    this.dfr = item;
endfunction : write

`endif // UART_DRV__SV
