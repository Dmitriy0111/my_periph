/*
*  File            :   sif_mth.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.09
*  Language        :   SystemVerilog
*  Description     :   This is simple interface common methods 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef SIF_MTH__SV
`define SIF_MTH__SV

class sif_mth extends dvv_bc;
    `OBJ_BEGIN( sif_mth )

    virtual simple_if   vif;

    extern function new(string name = "", dvv_bc parent = null);

    extern task                    set_addr(logic [31 : 0] val);
    extern function logic [31 : 0] get_addr();
    extern task                    set_re(logic [0  : 0] val);
    extern function logic [0  : 0] get_re();
    extern task                    set_we(logic [0  : 0] val);
    extern function logic [0  : 0] get_we();
    extern task                    set_wd(logic [31 : 0] val);
    extern function logic [31 : 0] get_wd();
    extern task                    set_rd(logic [31 : 0] val);
    extern function logic [31 : 0] get_rd();

    extern task                    wait_clk();
    extern task                    wait_reset();
    extern task                    reset_signals();
    
endclass : sif_mth

function sif_mth::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task                    sif_mth::set_addr(logic [31 : 0] val);
    vif.addr = val;
endtask : set_addr

function logic [31 : 0] sif_mth::get_addr();
    return vif.addr;
endfunction : get_addr

task                    sif_mth::set_re(logic [0  : 0] val);
    vif.re = val;
endtask : set_re

function logic [0  : 0] sif_mth::get_re();
    return vif.re;
endfunction : get_re

task                    sif_mth::set_we(logic [0  : 0] val);
    vif.we = val;
endtask : set_we

function logic [0  : 0] sif_mth::get_we();
    return vif.we;
endfunction : get_we

task                    sif_mth::set_wd(logic [31 : 0] val);
    vif.wd = val;
endtask : set_wd

function logic [31 : 0] sif_mth::get_wd();
    return vif.wd;
endfunction : get_wd

task                    sif_mth::set_rd(logic [31 : 0] val);
    vif.rd = val;
endtask : set_rd

function logic [31 : 0] sif_mth::get_rd();
    return vif.rd;
endfunction : get_rd

task sif_mth::wait_clk();
    @(posedge vif.clk);
endtask : wait_clk

task sif_mth::wait_reset();
    @(posedge vif.rstn);
endtask : wait_reset

task sif_mth::reset_signals();
    vif.addr = '0;
    vif.we = '0;
    vif.re = '0;
    vif.wd = '0;
endtask : reset_signals

`endif // SIF_MTH__SV