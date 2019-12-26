/*
*  File            :   uart_dtest.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.25
*  Language        :   SystemVerilog
*  Description     :   This is simple interface generator 
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef UART_DTEST__SV
`define UART_DTEST__SV

class uart_dtest extends dvv_test;

    sif_dgen                    d_gen;
    sif_drv                     drv;
    sif_mon                     mon;
    uart_mon                    u_mon;

    dvv_sock    #(sif_trans)    gen2drv_sock;

    extern function new(string name = "", dvv_bc parent = null);

    extern task     build();
    extern task     connect();
    extern task     run();
    
endclass : uart_dtest

function uart_dtest::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task uart_dtest::build();
    d_gen = sif_dgen::create::create_obj("[ DIRECT GEN ]", this);
    drv   = sif_drv ::create::create_obj("[ SIF    DRV ]", this);
    mon   = sif_mon ::create::create_obj("[ SIF    MON ]", this);
    u_mon = uart_mon::create::create_obj("[ UART   MON ]", this);

    d_gen.build();
    drv.build();
    mon.build();
    u_mon.build();

    gen2drv_sock = new();
    if( gen2drv_sock == null )
        $fatal("gen2drv_sock not created!");
endtask : build

task uart_dtest::connect();
    drv.item_sock.connect(gen2drv_sock);
    d_gen.item_sock.connect(gen2drv_sock);
endtask : connect

task uart_dtest::run();
    fork
        d_gen.run();
        drv.run();
        mon.run();
        u_mon.run();
    join_none
endtask : run

`endif // UART_DTEST__SV
