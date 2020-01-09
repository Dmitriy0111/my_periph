/*
*  File            :   ahb_mth.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.09
*  Language        :   SystemVerilog
*  Description     :   This is ahb interface common methods 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef AHB_MTH__SV
`define AHB_MTH__SV

class ahb_mth extends dvv_bc;
    `OBJ_BEGIN( ahb_mth )

    virtual ahb_if      vif;

    extern function new(string name = "", dvv_bc parent = null);

    extern task                    set_haddr(logic [31 : 0] val);
    extern function logic [31 : 0] get_haddr();
    extern task                    set_hrdata(logic [31 : 0] val);
    extern function logic [31 : 0] get_hrdata();
    extern task                    set_hwdata(logic [31 : 0] val);
    extern function logic [31 : 0] get_hwdata();
    extern task                    set_hwrite(logic [0  : 0] val);
    extern function logic [0  : 0] get_hwrite();
    extern task                    set_htrans(logic [1  : 0] val);
    extern function logic [1  : 0] get_htrans();
    extern task                    set_hsize(logic [2  : 0] val);
    extern function logic [2  : 0] get_hsize();
    extern task                    set_hburst(logic [2  : 0] val);
    extern function logic [2  : 0] get_hburst();
    extern task                    set_hresp(logic [1  : 0] val);
    extern function logic [1  : 0] get_hresp();
    extern task                    set_hready(logic [0  : 0] val);
    extern function logic [0  : 0] get_hready();
    extern task                    set_hsel(logic [0  : 0] val);
    extern function logic [0  : 0] get_hsel();

    extern task                    wait_clk();
    extern task                    wait_reset();
    
endclass : ahb_mth

function ahb_mth::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task                    ahb_mth::set_haddr(logic [31 : 0] val);
    vif.haddr = val;
endtask : set_haddr

function logic [31 : 0] ahb_mth::get_haddr();
    return vif.haddr;
endfunction : get_haddr

task                    ahb_mth::set_hrdata(logic [31 : 0] val);
    vif.hrdata = val;
endtask : set_hrdata

function logic [31 : 0] ahb_mth::get_hrdata();
    return vif.hrdata;
endfunction : get_hrdata

task                    ahb_mth::set_hwdata(logic [31 : 0] val);
    vif.hwdata = val;
endtask : set_hwdata

function logic [31 : 0] ahb_mth::get_hwdata();
    return vif.hwdata;
endfunction : get_hwdata

task                    ahb_mth::set_hwrite(logic [0  : 0] val);
    vif.hwrite = val;
endtask : set_hwrite

function logic [0  : 0] ahb_mth::get_hwrite();
    return vif.hwrite;
endfunction : get_hwrite

task                    ahb_mth::set_htrans(logic [1  : 0] val);
    vif.htrans = val;
endtask : set_htrans

function logic [1  : 0] ahb_mth::get_htrans();
    return vif.htrans;
endfunction : get_htrans

task                    ahb_mth::set_hsize(logic [2  : 0] val);
    vif.hsize = val;
endtask : set_hsize

function logic [2  : 0] ahb_mth::get_hsize();
    return vif.hsize;
endfunction : get_hsize

task                    ahb_mth::set_hburst(logic [2  : 0] val);
    vif.hburst = val;
endtask : set_hburst

function logic [2  : 0] ahb_mth::get_hburst();
    return vif.hburst;
endfunction : get_hburst

task                    ahb_mth::set_hresp(logic [1  : 0] val);
    vif.hresp = val;
endtask : set_hresp

function logic [1  : 0] ahb_mth::get_hresp();
    return vif.hresp;
endfunction : get_hresp

task                    ahb_mth::set_hready(logic [0  : 0] val);
    vif.hready = val;
endtask : set_hready

function logic [0  : 0] ahb_mth::get_hready();
    return vif.hready;
endfunction : get_hready

task                    ahb_mth::set_hsel(logic [0  : 0] val);
    vif.hsel = val;
endtask : set_hsel

function logic [0  : 0] ahb_mth::get_hsel();
    return vif.hsel;
endfunction : get_hsel

task ahb_mth::wait_clk();
    @(posedge vif.hclk);
endtask : wait_clk

task ahb_mth::wait_reset();
    @(posedge vif.hresetn);
endtask : wait_reset

`endif // AHB_MTH__SV
