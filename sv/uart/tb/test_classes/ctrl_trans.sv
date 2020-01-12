/*
*  File            :   ctrl_trans.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is control transaction 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef CTRL_TRANS__SV
`define CTRL_TRANS__SV

class ctrl_trans extends dvv_bc;
    `OBJ_BEGIN( ctrl_trans )

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

    extern task     print();

    extern task     make_tr();
    
endclass : ctrl_trans

function ctrl_trans::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task ctrl_trans::print();
    $display("data = %c (%h)", data, data);
endtask : print

task ctrl_trans::make_tr();
    if( !this.randomize() )
        $fatal("Randomization error!");
    tr_num ++;
endtask : make_tr

`endif // CTRL_TRANS__SV
