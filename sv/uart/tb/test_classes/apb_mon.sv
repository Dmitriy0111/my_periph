/*
*  File            :   apb_mon.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is apb interface monitor 
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef APB_MON__SV
`define APB_MON__SV

class apb_mon extends dvv_mon #(sif_trans);

    `OBJ_BEGIN( apb_mon )

    virtual apb_if  vif;

    extern function new(string name = "", dvv_bc parent = null);

    extern task     wait_clk();

    extern task     build();
    extern task     run();
    
endclass : apb_mon

function apb_mon::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task apb_mon::wait_clk();
    @(posedge vif.pclk);
endtask : wait_clk

task apb_mon::build();
    if( !dvv_res_db#(virtual apb_if)::get_res_db("apb_if_0",vif) )
        $fatal();
    $display("%s build complete", this.name);
endtask : build

task apb_mon::run();
    forever
    begin
        this.wait_clk();
        #0;
        if( vif.psel && (   vif.pwrite ) && vif.penable )
        begin
            $display("WRITE_TR addr = 0x%h, data = 0x%h", vif.paddr, vif.pwdata);
        end
        else if( vif.psel && ( ~ vif.pwrite ) && vif.penable )
        begin
            $display("READ_TR  addr = 0x%h, data = 0x%h", vif.paddr, vif.prdata);
        end
    end
endtask : run

`endif // APB_MON__SV
