/*
*  File            :   base_ctrl_agt.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.28
*  Language        :   SystemVerilog
*  Description     :   This is base ctrl interface agent 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef BASE_CTRL_AGT__SV
`define BASE_CTRL_AGT__SV

virtual class base_ctrl_agt extends dvv_agt;

    base_ctrl_drv   drv;
    base_ctrl_mon   mon;

    extern function new(string name = "", dvv_bc parent = null);

    pure virtual task build();
    
endclass : base_ctrl_agt

function base_ctrl_agt::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

`endif // BASE_CTRL_AGT__SV
