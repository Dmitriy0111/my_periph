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
    
endclass : uart_dtest

function uart_dtest::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task uart_dtest::build();
    super.build();

    if( !dvv_res_db#(string)::get_res_db("test_if",if_name) )
        $fatal();

    case( if_name )
        "sif_if"    : env = sif_env::create::create_obj("sif_env", this);
        "apb_if"    : env = apb_env::create::create_obj("apb_env", this);
        "ahb_if"    : env = ahb_env::create::create_obj("ahb_env", this);
        "avalon_if" : env = avalon_env::create::create_obj("avalon_env", this);
        default     : $fatal("Enviroment undefined");
    endcase

endtask : build

`endif // UART_DTEST__SV
