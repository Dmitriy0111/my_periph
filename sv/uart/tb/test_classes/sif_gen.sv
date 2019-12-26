/*
*  File            :   sif_gen.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is simple interface generator 
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef SIF_GEN__SV
`define SIF_GEN__SV

class sif_gen extends dvv_gen #(sif_trans);

    `OBJ_BEGIN( sif_gen )

    sif_trans   item;

    virtual clk_rst_if  vif;

    extern function new(string name = "", dvv_bc parent = null);

    extern task     build();
    extern task     run();
    
endclass : sif_gen

function sif_gen::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task sif_gen::build();
endtask : build

task sif_gen::run();
endtask : run

`endif // SIF_GEN__SV
