/*
*  File            :   uart_rtest.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.25
*  Language        :   SystemVerilog
*  Description     :   This is simple interface generator 
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef UART_RTEST__SV
`define UART_RTEST__SV

class uart_rtest extends dvv_test;

    string                      if_name;

    sif_rgen                    r_gen;
    dvv_drv     #(sif_trans)    drv;
    dvv_mon     #(sif_trans)    mon;
    uart_mon                    u_mon;

    dvv_sock    #(sif_trans)    gen2drv_sock;

    extern function new(string name = "", dvv_bc parent = null);

    extern task     build();
    extern task     connect();
    extern task     run();
    
endclass : uart_rtest

function uart_rtest::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task uart_rtest::build();
    if( !dvv_res_db#(string)::get_res_db("test_if",if_name) )
        $fatal();

    if( if_name == "sif_if" )
    begin
        drv   = sif_drv ::create::create_obj("[ SIF    DRV ]", this);
        mon   = sif_mon ::create::create_obj("[ SIF    MON ]", this);
    end 
    else if( if_name == "apb_if" )
    begin
        drv   = apb_drv ::create::create_obj("[ APB    DRV ]", this);
        mon   = apb_mon ::create::create_obj("[ APB    MON ]", this);
    end

    r_gen = sif_rgen::create::create_obj("[ RAND GEN ]", this);
    u_mon = uart_mon::create::create_obj("[ UART MON ]", this);

    r_gen.build();
    drv.build();
    mon.build();
    u_mon.build();

    gen2drv_sock = new();
    if( gen2drv_sock == null )
        $fatal("gen2drv_sock not created!");
endtask : build

task uart_rtest::connect();
    drv.item_sock.connect(gen2drv_sock);
    r_gen.item_sock.connect(gen2drv_sock);
endtask : connect

task uart_rtest::run();
    fork
        r_gen.run();
        drv.run();
        mon.run();
        u_mon.run();
    join_none
endtask : run

`endif // UART_RTEST__SV
