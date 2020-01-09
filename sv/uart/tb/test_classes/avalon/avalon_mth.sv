/*
*  File            :   avalon_mth.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.09
*  Language        :   SystemVerilog
*  Description     :   This is avalon interface common methods 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef AVALON_MTH__SV
`define AVALON_MTH__SV

class avalon_mth extends dvv_bc;
    `OBJ_BEGIN( avalon_mth )

    virtual avalon_if   vif;

    extern function new(string name = "", dvv_bc parent = null);

    extern task                    set_address(logic [31 : 0] val);
    extern function logic [31 : 0] get_address();
    extern task                    set_readdata(logic [31 : 0] val);
    extern function logic [31 : 0] get_readdata();
    extern task                    set_writedata(logic [31 : 0] val);
    extern function logic [31 : 0] get_writedata();
    extern task                    set_chipselect(logic [0  : 0] val);
    extern function logic [0  : 0] get_chipselect();
    extern task                    set_write(logic [0  : 0] val);
    extern function logic [0  : 0] get_write();

    extern function bit   [0  : 0] read_detect();
    extern function bit   [0  : 0] write_detect();

    extern task                    wait_clk();
    extern task                    wait_reset();
    
endclass : avalon_mth

function avalon_mth::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task                    avalon_mth::set_address(logic [31 : 0] val);
    vif.address = val;
endtask : set_address

function logic [31 : 0] avalon_mth::get_address();
    return vif.address;
endfunction : get_address

task                    avalon_mth::set_readdata(logic [31 : 0] val);
    vif.readdata = val;
endtask : set_readdata

function logic [31 : 0] avalon_mth::get_readdata();
    return vif.readdata;
endfunction : get_readdata

task                    avalon_mth::set_writedata(logic [31 : 0] val);
    vif.writedata = val;
endtask : set_writedata

function logic [31 : 0] avalon_mth::get_writedata();
    return vif.writedata;
endfunction : get_writedata

task                    avalon_mth::set_chipselect(logic [0  : 0] val);
    vif.chipselect = val;
endtask : set_chipselect

function logic [0  : 0] avalon_mth::get_chipselect();
    return vif.chipselect;
endfunction : get_chipselect

task                    avalon_mth::set_write(logic [0  : 0] val);
    vif.write = val;
endtask : set_write

function logic [0  : 0] avalon_mth::get_write();
    return vif.write;
endfunction : get_write

function bit   [0  : 0] avalon_mth::read_detect();
    return ( vif.chipselect && ( ~ vif.write ) ) ? '1 : '0;
endfunction : read_detect

function bit   [0  : 0] avalon_mth::write_detect();
    return ( vif.chipselect && (   vif.write ) ) ? '1 : '0;
endfunction : write_detect

task avalon_mth::wait_clk();
    @(posedge vif.clk);
endtask : wait_clk

task avalon_mth::wait_reset();
    @(posedge vif.rstn);
endtask : wait_reset

`endif // AVALON_MTH__SV
