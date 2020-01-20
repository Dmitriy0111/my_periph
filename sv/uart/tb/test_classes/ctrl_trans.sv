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

    rand    logic   [31 : 0]    data;
            logic   [31 : 0]    addr;
            logic   [0  : 0]    we_re;

    int     tr_num = 0;

    constraint data_tr_c {
        data inside { [0 : 2**8-1] };
    }

    constraint data_freq_c {
        data inside { 40, 50, 60, 70, 100 };
    }

    extern function new(string name = "", dvv_bc parent = null);

    extern task print();

    extern task set_we_re(logic [0 : 0] we_re);
    extern task set_data(logic [31 : 0] data);
    extern task set_addr(logic [31 : 0] addr);

    extern function logic [0  : 0] get_we_re();
    extern function logic [31 : 0] get_data();
    extern function logic [31 : 0] get_addr();

    extern task make_tr();

    extern function ctrl_trans copy();
    
endclass : ctrl_trans

function ctrl_trans::new(string name = "", dvv_bc parent = null);
endfunction : new

task ctrl_trans::print();
    $display("data  : 0x%h", data);
    $display("addr  : 0x%h", addr);
    $display("we_re : %s", ( we_re ? "WRITE" : "READ ") );
endtask : print

task ctrl_trans::set_we_re(logic [0 : 0] we_re);
    this.we_re = we_re;
endtask : set_we_re

task ctrl_trans::set_data(logic [31 : 0] data);
    this.data = data;
endtask : set_data

task ctrl_trans::set_addr(logic [31 : 0] addr);
    this.addr = addr;
endtask : set_addr

function logic [0  : 0] ctrl_trans::get_we_re();
    return this.we_re;
endfunction : get_we_re

function logic [31 : 0] ctrl_trans::get_data();
    return this.data;
endfunction : get_data

function logic [31 : 0] ctrl_trans::get_addr();
    return this.addr;
endfunction : get_addr

task ctrl_trans::make_tr();
    if( !this.randomize() )
        $fatal("Randomization error!");
    tr_num ++;
endtask : make_tr

function ctrl_trans ctrl_trans::copy();
    copy = new();
    copy.addr = this.addr;
    copy.data = this.data;
    copy.we_re = this.we_re;
    return copy;
endfunction : copy

`endif // CTRL_TRANS__SV
