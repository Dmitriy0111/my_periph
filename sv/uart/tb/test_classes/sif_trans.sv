/*
*  File            :   sif_trans.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is simple interface transaction 
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef SIF_TRANS__SV
`define SIF_TRANS__SV

class sif_trans extends dvv_bc;

    `OBJ_BEGIN( sif_trans )

    rand    logic   [7  : 0]    data;
    rand    logic   [15 : 0]    freq;

    int     tr_num = 0;

    constraint freq_c {
        freq inside { [20 : 200] };
    }

    constraint data_c {
        data inside { [0 : 2**8-1] };
    }

    extern function new(string name = "", dvv_bc parent = null);

    extern task     make_tr();
    
endclass : sif_trans

function sif_trans::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task sif_trans::make_tr();
    if( !this.randomize() )
        $fatal("Randomization error!");
    tr_num ++;
endtask : make_tr

`endif // SIF_TRANS__SV
