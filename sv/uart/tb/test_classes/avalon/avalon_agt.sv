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

class avalon_agt extends dvv_agt;
    `OBJ_BEGIN( avalon_agt )

    avalon_drv  drv;
    avalon_mon  mon;

    extern function new(string name = "", dvv_bc parent = null);

    extern task build();
    extern task run();
    
endclass : avalon_agt

function avalon_agt::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task avalon_agt::build();
    drv = avalon_drv::create::create_obj("[ AVALON DRV ]", this);
    mon = avalon_mon::create::create_obj("[ AVALON MON ]", this);

    drv.build();
    mon.build();
endtask : build

task avalon_agt::run();
    fork
        drv.run();
        mon.run();
    join_none
endtask : run

`endif // AVALON_AGT__SV
