/*
*  File            :   apb_env.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.09
*  Language        :   SystemVerilog
*  Description     :   This is apb enviroment
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef APB_ENV__SV
`define APB_ENV__SV

class apb_env extends dvv_env;
    `OBJ_BEGIN( apb_env )

    tr_gen                      gen;
    apb_agt                     agt;
    uart_agt                    u_agt;

    dvv_sock    #(ctrl_trans)   gen2drv_sock;
    dvv_sock    #(ctrl_trans)   drv2gen_sock;

    string                      test_type;

    extern function new(string name = "", dvv_bc parent = null);

    extern task build();
    extern task connect();
    extern task run();
    
endclass : apb_env

function apb_env::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task apb_env::build();
    if( !dvv_res_db#(string)::get_res_db("test_type",test_type) )
        $fatal();

    agt = apb_agt::create::create_obj("[ APB AGT ]",this);

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

    gen2drv_sock = new();
    if( gen2drv_sock == null )
        $fatal("gen2drv_sock not created!");

    drv2gen_sock = new();
    if( drv2gen_sock == null )
        $fatal("drv2gen_sock not created!");
    $display("%s build complete", this.fname);
endtask : build

task apb_env::connect();
    agt.drv.item_sock.connect(gen2drv_sock);
    gen.item_sock.connect(gen2drv_sock);

    agt.drv.resp_sock.connect(drv2gen_sock);
    gen.resp_sock.connect(drv2gen_sock);

    gen.u_agt_aep.connect(u_agt.mon.mon_ap);
    gen.u_agt_aep.connect(u_agt.drv.drv_ap);
endtask : connect

task apb_env::run();
    fork
        gen.run();
        agt.run();
        u_agt.run();
    join_none
endtask : run

`endif // APB_ENV__SV
