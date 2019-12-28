/*
*  File            :   apb_agt.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is apb interface monitor 
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef APB_AGT__SV
`define APB_AGT__SV

class apb_agt extends dvv_agt #(sif_trans);

    `OBJ_BEGIN( apb_agt )

    extern function new(string name = "", dvv_bc parent = null);

    extern task     build();
    extern task     run();
    
endclass : apb_agt

function apb_agt::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task apb_agt::build();
    drv = apb_drv ::create::create_obj("[ APB DRV ]", this);
    mon = apb_mon ::create::create_obj("[ APB MON ]", this);

    drv.build();
    mon.build();

    $display("%s build complete", this.name);
endtask : build

task apb_agt::run();
    fork
        drv.run();
        mon.run();
    join_none
endtask : run

`endif // APB_AGT__SV
