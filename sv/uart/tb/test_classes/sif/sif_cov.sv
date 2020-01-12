/*
*  File            :   sif_cov.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.10
*  Language        :   SystemVerilog
*  Description     :   This is simple interface coverage class 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef SIF_COV__SV
`define SIF_COV__SV

class sif_cov extends dvv_scr #(ctrl_trans);
    `OBJ_BEGIN( sif_cov )

    extern function new(string name = "", dvv_bc parent = null);

    extern function write(ctrl_trans item);
    
endclass : sif_cov

function sif_cov::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
    item_ap = new(this);
endfunction : new

function sif_cov::write(ctrl_trans item);
    $info("%s",this.fname);
    item.print();
endfunction : write

`endif // SIF_COV__SV
