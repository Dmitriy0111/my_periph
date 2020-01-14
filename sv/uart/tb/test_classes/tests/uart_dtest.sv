/*
*  File            :   uart_dtest.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.25
*  Language        :   SystemVerilog
*  Description     :   This is simple interface generator 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef UART_DTEST__SV
`define UART_DTEST__SV

class uart_dtest extends uart_test;
    `OBJ_BEGIN( uart_dtest )

    string                      if_name;

    dvv_env                     env;

    extern function new(string name = "", dvv_bc parent = null);

    extern task build();
    extern task connect();
    extern task run();

    extern task test_start();
    
endclass : uart_dtest

function uart_dtest::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task uart_dtest::build();
    if( !dvv_res_db#(string)::get_res_db("test_if",if_name) )
        $fatal();

    case( if_name )
        "sif_if"    : env = sif_env::create::create_obj("[ SIF ENV ]", this);
        "apb_if"    : env = apb_env::create::create_obj("[ APB ENV ]", this);
        "ahb_if"    : env = ahb_env::create::create_obj("[ AHB ENV ]", this);
        "avalon_if" : env = avalon_env::create::create_obj("[ AVALON ENV ]", this);
        default     : $fatal("Enviroment undefined");
    endcase

    env.build();

    $display("%s build complete", this.fname);
endtask : build

task uart_dtest::connect();
    env.connect();
endtask : connect

task uart_dtest::run();
    fork
        env.run();
    join_none
endtask : run

task uart_dtest::test_start();
    $display("%s build phase start.", this.fname);
    this.build();
    $display("%s build phase complete.", this.fname);

    $display("%s connect phase start.", this.fname);
    this.connect();
    $display("%s connect phase complete.", this.fname);

    $display("%s run phase start.", this.fname);
    this.run();
    $display("%s run phase complete.", this.fname);
endtask : test_start

`endif // UART_DTEST__SV
