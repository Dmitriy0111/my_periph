/*
*  File            :   ahb_agt.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.09
*  Language        :   SystemVerilog
*  Description     :   This is ahb interface monitor 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef AHB_AGT__SV
`define AHB_AGT__SV

class ahb_agt extends dvv_agt;
    `OBJ_BEGIN( ahb_agt )

    ahb_drv     drv;
    ahb_mon     mon;

    extern function new(string name = "", dvv_bc parent = null);

    extern task build();
    
endclass : ahb_agt

function ahb_agt::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task ahb_agt::build();
    drv = ahb_drv ::create::create_obj("[ AHB DRV ]", this);
    mon = ahb_mon ::create::create_obj("[ AHB MON ]", this);
endtask : build

`endif // AHB_AGT__SV
