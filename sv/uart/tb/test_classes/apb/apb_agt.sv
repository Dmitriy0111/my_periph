/*
*  File            :   apb_agt.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is apb interface monitor 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef APB_AGT__SV
`define APB_AGT__SV

class apb_agt extends base_ctrl_agt;
    `OBJ_BEGIN( apb_agt )

    apb_drv     drv;
    apb_mon     mon;

    extern function new(string name = "", dvv_bc parent = null);

    extern task build();
    
endclass : apb_agt

function apb_agt::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task apb_agt::build();
    drv = apb_drv ::create::create_obj("apb_drv", this);
    mon = apb_mon ::create::create_obj("apb_mon", this);
endtask : build

`endif // APB_AGT__SV
