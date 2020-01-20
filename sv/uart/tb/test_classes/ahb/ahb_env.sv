/*
*  File            :   ahb_env.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.09
*  Language        :   SystemVerilog
*  Description     :   This is ahb enviroment
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef AHB_ENV__SV
`define AHB_ENV__SV

class ahb_env extends dvv_env;
    `OBJ_BEGIN( ahb_env )

    dvv_gen     #(ctrl_trans)   gen;
    ahb_agt                     agt;
    uart_mon                    u_mon;

    dvv_sock    #(ctrl_trans)   gen2drv_sock;

    string                      test_type;

    extern function new(string name = "", dvv_bc parent = null);

    extern task build();
    extern task connect();
    
endclass : ahb_env

function ahb_env::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task ahb_env::build();
    if( !dvv_res_db#(string)::get_res_db("test_type",test_type) )
        $fatal();

    agt = ahb_agt::create::create_obj("[ AHB AGT ]",this);

    if( test_type == "direct_test" )
    begin
        gen = tr_dgen ::create::create_obj("[ DIRECT GEN ]", this);
    end 
    else if( test_type == "rand_test" )
    begin
        gen = tr_rgen ::create::create_obj("[ RANDOM GEN ]", this);
    end

    u_mon = uart_mon::create::create_obj("[ UART MON ]", this);

    gen2drv_sock = new();
    if( gen2drv_sock == null )
        $fatal("gen2drv_sock not created!");
endtask : build

task ahb_env::connect();
    agt.drv.item_sock.connect(gen2drv_sock);
    gen.item_sock.connect(gen2drv_sock);

    agt.drv.u_mon_aep.connect(u_mon.mon_ap);
endtask : connect

`endif // AHB_ENV__SV
