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

    tr_gen                      gen;
    sif_agt                     agt;
    sif_cov                     cov;
    uart_agt                    u_agt;
    test_scb                    scb;

    dvv_sock    #(ctrl_trans)   gen2drv_sock;
    dvv_sock    #(ctrl_trans)   drv2gen_sock;

    string                      test_type;

    extern function new(string name = "", dvv_bc parent = null);

    extern task build();
    extern task connect();
    extern task run();
    
endclass : sif_env

function sif_env::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task sif_env::build();
    if( !dvv_res_db#(string)::get_res_db("test_type",test_type) )
        $fatal();

    agt = sif_agt ::create::create_obj("[ SIF AGT ]", this);
    cov = sif_cov ::create::create_obj("[ SIF COV ]", this);
    
    scb = test_scb::create::create_obj("[ TEST SCB ]", this);

    if( test_type == "direct_test" )
    begin
        gen = tr_dgen ::create::create_obj("[ DIRECT GEN ]", this);
    end 
    else if( test_type == "rand_test" )
    begin
        gen = tr_rgen ::create::create_obj("[ RANDOM GEN ]", this);
    end

    u_agt = uart_agt::create::create_obj("[ UART AGT ]", this);
    
    gen.build();
    agt.build();
    u_agt.build();
    scb.build();

    gen2drv_sock = new();
    if( gen2drv_sock == null )
        $fatal("gen2drv_sock not created!");

    drv2gen_sock = new();
    if( drv2gen_sock == null )
        $fatal("drv2gen_sock not created!");
endtask : build

task sif_env::connect();
    agt.drv.item_sock.connect(gen2drv_sock);
    gen.item_sock.connect(gen2drv_sock);

    agt.drv.resp_sock.connect(drv2gen_sock);
    gen.resp_sock.connect(drv2gen_sock);
    
    agt.mon.cov_aep.connect(cov.item_ap);

    gen.u_agt_aep.connect(u_agt.mon.mon_ap);
    gen.u_agt_aep.connect(u_agt.drv.drv_ap);

    gen.scb_aep.connect(scb.ctrl_ap);
    u_agt.mon.mon_aep.connect(scb.uart_ap);
endtask : connect

task sif_env::run();
    fork
        gen.run();
        agt.run();
        u_agt.run();
        scb.run();
    join_none
endtask : run

`endif // SIF_ENV__SV
