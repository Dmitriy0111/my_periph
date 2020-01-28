/*
*  File            :   avalon_env.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.09
*  Language        :   SystemVerilog
*  Description     :   This is avalon enviroment
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef AVALON_ENV__SV
`define AVALON_ENV__SV

class avalon_env extends dvv_env;
    `OBJ_BEGIN( avalon_env )

    tr_gen                      gen;
    avalon_agt                  agt;
    // avalon_cov                  cov;
    uart_agt                    u_agt;
    test_scb                    scb;

    dvv_sock    #(ctrl_trans)   drv2gen_sock;
    dvv_sock    #(ctrl_trans)   gen2drv_sock;

    string                      test_type;

    extern function new(string name = "", dvv_bc parent = null);

    extern task build();
    extern task connect();
    
endclass : avalon_env

function avalon_env::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task avalon_env::build();
    if( !dvv_res_db#(string)::get_res_db("test_type",test_type) )
        $fatal();

    agt = avalon_agt::create::create_obj("avalon_agt",this);
    // cov = avalon_cov ::create::create_obj("avalon_cov", this);

    scb = test_scb::create::create_obj("test_scb", this);

    if( test_type == "direct_test" )
    begin
        gen = tr_dgen ::create::create_obj("direct_gen", this);
    end 
    else if( test_type == "rand_test" )
    begin
        gen = tr_rgen ::create::create_obj("random_gen", this);
    end

    u_agt = uart_agt::create::create_obj("uart_agt", this);

    gen2drv_sock = new();
    if( gen2drv_sock == null )
        $fatal("gen2drv_sock not created!");

    drv2gen_sock = new();
    if( drv2gen_sock == null )
        $fatal("drv2gen_sock not created!");
endtask : build

task avalon_env::connect();
    agt.drv.item_sock.connect(gen2drv_sock);
    gen.item_sock.connect(gen2drv_sock);

    agt.drv.resp_sock.connect(drv2gen_sock);
    gen.resp_sock.connect(drv2gen_sock);

    gen.u_agt_aep.connect(u_agt.mon.mon_ap);
    gen.u_agt_aep.connect(u_agt.drv.drv_ap);

    gen.scb_aep.connect(scb.ctrl_ap);
    u_agt.mon.mon_aep.connect(scb.uart_ap);
endtask : connect

`endif // AVALON_ENV__SV
