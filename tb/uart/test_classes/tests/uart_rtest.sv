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

    dvv_bc                     env;

    extern function new(string name = "", dvv_bc parent = null);

    extern task build();
    
endclass : uart_rtest

function uart_rtest::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task uart_rtest::build();
    string env_name;
    super.build();

    if( !dvv_res_db#(string)::get_res_db("test_if",if_name) )
        $fatal();

    env_name = { if_name.substr(0,if_name.len()-3) , "env" };
    foreach(type_bc[i])
    begin
        print({i,"\n"});
        if( env_name == i )
        begin
            env = type_bc[i].create_obj(env_name, this);
            print( "Enviroment found!\n" );
        end
    end
    //case( if_name )
    //    "sif_if"    : env = sif_env::create::create_obj("sif_env", this);
    //    "apb_if"    : env = apb_env::create::create_obj("apb_env", this);
    //    "ahb_if"    : env = ahb_env::create::create_obj("ahb_env", this);
    //    "avalon_if" : env = avalon_env::create::create_obj("avalon_env", this);
    //    default     : $fatal("Enviroment undefined");
    //endcase
endtask : build

`endif // UART_RTEST__SV
