/*
*  File            :   sif_env.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.09
*  Language        :   SystemVerilog
*  Description     :   This is sif enviroment
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef SIF_ENV__SV
`define SIF_ENV__SV

class sif_env extends dvv_env;
    `OBJ_BEGIN( sif_env )

    dvv_gen     #(ctrl_trans)   gen;
    sif_agt                     agt;
    uart_mon                    u_mon;

    dvv_sock    #(ctrl_trans)   gen2drv_sock;

    string                      test_type;

    extern function new(string name = "", dvv_bc parent = null);

    extern task     build();
    extern task     run();
    extern task     connect();
    
endclass : sif_env

function sif_env::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task sif_env::build();
    if( !dvv_res_db#(string)::get_res_db("test_type",test_type) )
        $fatal();

    agt = sif_agt ::create::create_obj("[ SIF AGT ]",this);

    if( test_type == "direct_test" )
    begin
        gen = tr_dgen ::create::create_obj("[ DIRECT GEN ]", this);
    end 
    else if( test_type == "rand_test" )
    begin
        gen = tr_rgen ::create::create_obj("[ RANDOM GEN ]", this);
    end

    u_mon = uart_mon::create::create_obj("[ UART MON ]", this);

    gen.build();
    agt.build();
    u_mon.build();

    gen2drv_sock = new();
    if( gen2drv_sock == null )
        $fatal("gen2drv_sock not created!");

    $display("%s build complete", this.fname);
endtask : build

task sif_env::connect();
    agt.drv.item_sock.connect(gen2drv_sock);
    gen.item_sock.connect(gen2drv_sock);
endtask : connect

task sif_env::run();
    fork
        gen.run();
        agt.run();
        u_mon.run();
    join_none
endtask : run

`endif // SIF_ENV__SV
