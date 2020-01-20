/*
*  File            :   uart_agt.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.14
*  Language        :   SystemVerilog
*  Description     :   This is uart interface agent 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef UART_AGT__SV
`define UART_AGT__SV

class uart_agt extends dvv_agt;
    `OBJ_BEGIN( uart_agt )

    uart_mon    mon;
    uart_drv    drv;

    extern function new(string name = "", dvv_bc parent = null);

    extern task build();
    
endclass : uart_agt

function uart_agt::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task uart_agt::build();
    mon = uart_mon::create::create_obj("[ UART MON ]", this);
    drv = uart_drv::create::create_obj("[ UART DRV ]", this);
endtask : build

`endif // UART_AGT__SV
