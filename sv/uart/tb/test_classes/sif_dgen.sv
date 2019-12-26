/*
*  File            :   sif_dgen.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is simple interface direct generator 
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef SIF_DGEN__SV
`define SIF_DGEN__SV

class sif_dgen extends sif_gen;

    `OBJ_BEGIN( sif_dgen )

    string  msg = "Hello World!";

    extern function new(string name = "", dvv_bc parent = null);

    extern task     build();
    extern task     run();
    
endclass : sif_dgen

function sif_dgen::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task sif_dgen::build();
    item = sif_trans::create::create_obj("gen_item",this);
    item_sock = new();
    if( !dvv_res_db#(virtual clk_rst_if)::get_res_db("cr_if_0",vif) )
        $fatal();
    $display("%s build complete", this.name);
endtask : build

task sif_dgen::run();
    @(posedge vif.rstn);
    item_sock.wait_sock();
    for(int i = 0 ; i < msg.len() ; i++ )
    begin
        item.tr_num++;
        item.data = msg[i];
        item_sock.send_msg(item);
        item_sock.wait_sock();
    end
    $stop;
endtask : run

`endif // SIF_DGEN__SV
