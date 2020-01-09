/*
*  File            :   uart_test.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.25
*  Language        :   SystemVerilog
*  Description     :   This is simple interface generator 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef UART_TEST__SV
`define UART_TEST__SV

class uart_test extends dvv_test;
    `OBJ_BEGIN( uart_test )

    extern function new(string name = "", dvv_bc parent = null);

    extern task     build();
    extern task     run();
    
endclass : uart_test

function uart_test::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task uart_test::build();
endtask : build

task uart_test::run();
endtask : run

`endif // UART_TEST__SV
