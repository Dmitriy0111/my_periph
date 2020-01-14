/*
*  File            :   ahb_mon.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.09
*  Language        :   SystemVerilog
*  Description     :   This is ahb interface monitor 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef AHB_MON__SV
`define AHB_MON__SV

class ahb_mon extends dvv_mon #(ctrl_trans);
    `OBJ_BEGIN( ahb_mon )

    virtual ahb_if  vif;

    extern function new(string name = "", dvv_bc parent = null);

    extern task wait_clk();

    extern task build();
    extern task run();
    
endclass : ahb_mon

function ahb_mon::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task ahb_mon::wait_clk();
    @(posedge vif.hclk);
endtask : wait_clk

task ahb_mon::build();
    if( !dvv_res_db#(virtual ahb_if)::get_res_db("ahb_if_0",vif) )
        $fatal();
    $display("%s build complete", this.fname);
endtask : build

task ahb_mon::run();
    forever
    begin
        this.wait_clk();
        #0;
        //if( vif.psel && (   vif.pwrite ) && vif.penable )
        //begin
        //    $display("WRITE_TR addr = 0x%h, data = 0x%h", vif.paddr, vif.pwdata);
        //end
        //else if( vif.psel && ( ~ vif.pwrite ) && vif.penable )
        //begin
        //    $display("READ_TR  addr = 0x%h, data = 0x%h", vif.paddr, vif.prdata);
        //end
    end
endtask : run

`endif // AHB_MON__SV
