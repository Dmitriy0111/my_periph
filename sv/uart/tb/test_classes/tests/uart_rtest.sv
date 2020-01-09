/*
*  File            :   uart_rtest.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.25
*  Language        :   SystemVerilog
*  Description     :   This is simple interface generator 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef UART_RTEST__SV
`define UART_RTEST__SV

class uart_rtest extends uart_test;
    `OBJ_BEGIN( uart_rtest )

    string                      if_name;

    dvv_env                     env;

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

    case( if_name )
        "simple_if" : env = sif_env::create::create_obj("[ SIF ENV ]", this);
        "apb_if"    : env = apb_env::create::create_obj("[ APB ENV ]", this);
        "ahb_if"    : env = ahb_env::create::create_obj("[ AHB ENV ]", this);
        "avalon_if" : env = avalon_env::create::create_obj("[ AVALON ENV ]", this);
        default     : $fatal("Enviroment undefined");
    endcase

    env.build();

    $display("%s build complete", this.fname);
endtask : build

task uart_rtest::connect();
    env.connect();
endtask : connect

task uart_rtest::run();
    fork
        env.run();
    join_none
endtask : run

`endif // UART_RTEST__SV