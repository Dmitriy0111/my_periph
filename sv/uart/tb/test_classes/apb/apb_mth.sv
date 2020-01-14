/*
*  File            :   apb_mth.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.09
*  Language        :   SystemVerilog
*  Description     :   This is apb interface common methods 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef APB_MTH__SV
`define APB_MTH__SV

class apb_mth extends dvv_bc;
    `OBJ_BEGIN( apb_mth )

    virtual apb_if      vif;

    extern function new(string name = "", dvv_bc parent = null);

    extern task set_paddr(logic [31 : 0] val);
    extern task set_prdata(logic [31 : 0] val);
    extern task set_pwdata(logic [31 : 0] val);
    extern task set_psel(logic [0  : 0] val);
    extern task set_penable(logic [0  : 0] val);
    extern task set_pwrite(logic [0  : 0] val);
    extern task set_pready(logic [0  : 0] val);
    extern task set_pslverr(logic [0  : 0] val);

    extern function logic [31 : 0] get_paddr();
    extern function logic [31 : 0] get_prdata();
    extern function logic [31 : 0] get_pwdata();
    extern function logic [0  : 0] get_psel();
    extern function logic [0  : 0] get_penable();
    extern function logic [0  : 0] get_pwrite();
    extern function logic [0  : 0] get_pready();
    extern function logic [0  : 0] get_pslverr();

    extern function bit [0  : 0] read_detect();
    extern function bit [0  : 0] write_detect();

    extern task wait_clk();
    extern task wait_reset();
    
endclass : apb_mth

function apb_mth::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task apb_mth::set_paddr(logic [31 : 0] val);
    vif.paddr = val;
endtask : set_paddr

task apb_mth::set_prdata(logic [31 : 0] val);
    vif.prdata = val;
endtask : set_prdata

task apb_mth::set_pwdata(logic [31 : 0] val);
    vif.pwdata = val;
endtask : set_pwdata

task apb_mth::set_psel(logic [0  : 0] val);
    vif.psel = val;
endtask : set_psel

task apb_mth::set_penable(logic [0  : 0] val);
    vif.penable = val;
endtask : set_penable

task apb_mth::set_pwrite(logic [0  : 0] val);
    vif.pwrite = val;
endtask : set_pwrite

task apb_mth::set_pready(logic [0  : 0] val);
    vif.pready = val;
endtask : set_pready

task apb_mth::set_pslverr(logic [0  : 0] val);
    vif.pslverr = val;
endtask : set_pslverr

function logic [31 : 0] apb_mth::get_paddr();
    return vif.paddr;
endfunction : get_paddr

function logic [31 : 0] apb_mth::get_prdata();
    return vif.prdata;
endfunction : get_prdata

function logic [31 : 0] apb_mth::get_pwdata();
    return vif.pwdata;
endfunction : get_pwdata

function logic [0  : 0] apb_mth::get_psel();
    return vif.psel;
endfunction : get_psel

function logic [0  : 0] apb_mth::get_penable();
    return vif.penable;
endfunction : get_penable

function logic [0  : 0] apb_mth::get_pwrite();
    return vif.pwrite;
endfunction : get_pwrite

function logic [0  : 0] apb_mth::get_pready();
    return vif.pready;
endfunction : get_pready

function logic [0  : 0] apb_mth::get_pslverr();
    return vif.pslverr;
endfunction : get_pslverr

function bit [0  : 0] apb_mth::read_detect();
    return ( this.get_psel() && (   this.get_pwrite() ) && this.get_penable() ) ? '1 : '0;
endfunction : read_detect

function bit [0  : 0] apb_mth::write_detect();
    return ( this.get_psel() && ( ~ this.get_pwrite() ) && this.get_penable() ) ? '1 : '0;
endfunction : write_detect

task apb_mth::wait_clk();
    @(posedge vif.pclk);
endtask : wait_clk

task apb_mth::wait_reset();
    @(posedge vif.presetn);
endtask : wait_reset

`endif // APB_MTH__SV
