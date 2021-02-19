/*
*  File            :   sif_agt.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is simple interface agent 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef SIF_AGT__SV
`define SIF_AGT__SV

class sif_agt extends base_ctrl_agt;
    `OBJ_BEGIN( sif_agt )

    extern function new(string name = "", dvv_bc parent = null);

    extern task build();
    
endclass : sif_agt

function sif_agt::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task sif_agt::build();
    drv = sif_drv ::create::create_obj("sif_drv", this);
    mon = sif_mon ::create::create_obj("sif_mon", this);
endtask : build

`endif // SIF_AGT__SV
