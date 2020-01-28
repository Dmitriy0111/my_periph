/*
*  File            :   base_ctrl_drv.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.28
*  Language        :   SystemVerilog
*  Description     :   This is base ctrl interface driver 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef BASE_CTRL_DRV__SV
`define BASE_CTRL_DRV__SV

virtual class base_ctrl_drv extends dvv_drv #(ctrl_trans);

    ctrl_trans                  item;
    ctrl_trans                  resp_item;

    extern function new(string name = "", dvv_bc parent = null);

    pure virtual task build();
    pure virtual task run();
    
endclass : base_ctrl_drv

function base_ctrl_drv::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

`endif // BASE_CTRL_DRV__SV
