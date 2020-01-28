/*
*  File            :   avalon_agt.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.09
*  Language        :   SystemVerilog
*  Description     :   This is avalon interface agent 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef AVALON_AGT__SV
`define AVALON_AGT__SV

class avalon_agt extends base_ctrl_agt;
    `OBJ_BEGIN( avalon_agt )

    extern function new(string name = "", dvv_bc parent = null);

    extern task build();
    
endclass : avalon_agt

function avalon_agt::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task avalon_agt::build();
    drv = avalon_drv::create::create_obj("avalon_drv", this);
    mon = avalon_mon::create::create_obj("avalon_mon", this);
endtask : build

`endif // AVALON_AGT__SV
