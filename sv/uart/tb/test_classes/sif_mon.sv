/*
*  File            :   sif_mon.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is simple interface monitor 
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef SIF_MON__SV
`define SIF_MON__SV

class sif_mon extends dvv_mon #(sif_trans);

    `OBJ_BEGIN( sif_mon )

    virtual simple_if   vif;

    extern function new(string name = "", dvv_bc parent = null);

    extern task     wait_clk();

    extern task     build();
    extern task     run();
    
endclass : sif_mon

function sif_mon::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task sif_mon::wait_clk();
    @(posedge vif.clk);
endtask : wait_clk

task sif_mon::build();
    if( !dvv_res_db#(virtual simple_if)::get_res_db("sif_0",vif) )
        $fatal();
    $display("%s build complete", this.name);
endtask : build

task sif_mon::run();
    forever
    begin
        this.wait_clk();
        #0;
        if( vif.we )
        begin
            $display("WRITE_TR addr = 0x%h, data = 0x%h", vif.addr, vif.wd);
        end
        else if( vif.re )
        begin
            $display("READ_TR  addr = 0x%h, data = 0x%h", vif.addr, vif.rd);
        end
    end
endtask : run

`endif // SIF_MON__SV
