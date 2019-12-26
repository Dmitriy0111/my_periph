/*
*  File            :   sif_rgen.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is simple interface random generator 
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef SIF_RGEN__SV
`define SIF_RGEN__SV

class sif_rgen extends sif_gen;

    `OBJ_BEGIN( sif_rgen )

    extern function new(string name = "", dvv_bc parent = null);

    extern task     build();
    extern task     run();
    
endclass : sif_rgen

function sif_rgen::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task sif_rgen::build();
    item = sif_trans::create::create_obj("gen_item",this);
    item_sock = new();
    if( !dvv_res_db#(virtual clk_rst_if)::get_res_db("cr_if_0",vif) )
        $fatal();
    $display("%s build complete", this.name);
endtask : build

task sif_rgen::run();
    @(posedge vif.rstn);
    item_sock.wait_sock();
    repeat(20)
    begin
        item.make_tr();
        item_sock.send_msg(item);
        item_sock.wait_sock();
    end
    $stop;
endtask : run

`endif // SIF_RGEN__SV
