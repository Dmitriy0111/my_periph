/*
*  File            :   base_ctrl_mon.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.28
*  Language        :   SystemVerilog
*  Description     :   This is base ctrl interface monitor 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef BASE_CTRL_MON__SV
`define BASE_CTRL_MON__SV

virtual class base_ctrl_mon extends dvv_mon #(ctrl_trans);

    string      msg;

    ctrl_trans  item;

    extern function new(string name = "", dvv_bc parent = null);

    pure virtual task build();
    pure virtual task run();
    
endclass : base_ctrl_mon

function base_ctrl_mon::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

`endif // BASE_CTRL_MON__SV
