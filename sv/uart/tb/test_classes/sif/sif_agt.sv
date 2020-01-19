/*
*  File            :   sif_agt.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is apb interface monitor 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef SIF_AGT__SV
`define SIF_AGT__SV

class sif_agt extends dvv_agt;
    `OBJ_BEGIN( sif_agt )

    sif_drv     drv;
    sif_mon     mon;

    extern function new(string name = "", dvv_bc parent = null);

    extern task build();
    extern task run();
    
endclass : sif_agt

function sif_agt::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task sif_agt::build();
    drv = sif_drv ::create::create_obj("[ SIF DRV ]", this);
    mon = sif_mon ::create::create_obj("[ SIF MON ]", this);

    drv.build();
    mon.build();
endtask : build

task sif_agt::run();
    fork
        drv.run();
        mon.run();
    join_none
endtask : run

`endif // SIF_AGT__SV
