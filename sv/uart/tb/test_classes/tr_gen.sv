/*
*  File            :   tr_gen.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is transaction generator 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef TR_GEN__SV
`define TR_GEN__SV

class tr_gen extends dvv_gen #(ctrl_trans);
    `OBJ_BEGIN( tr_gen )

    ctrl_trans  item;

    virtual clk_rst_if  vif;

    extern function new(string name = "", dvv_bc parent = null);

    extern task build();
    extern task run();
    
endclass : tr_gen

function tr_gen::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task tr_gen::build();
endtask : build

task tr_gen::run();
endtask : run

`endif // TR_GEN__SV
