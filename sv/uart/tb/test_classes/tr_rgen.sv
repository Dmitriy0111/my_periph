/*
*  File            :   tr_rgen.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is transaction random generator 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef TR_RGEN__SV
`define TR_RGEN__SV

class tr_rgen extends tr_gen;
    `OBJ_BEGIN( tr_rgen )

    integer     repeat_n;

    extern function new(string name = "", dvv_bc parent = null);

    extern task     build();
    extern task     run();
    
endclass : tr_rgen

function tr_rgen::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task tr_rgen::build();
    item = ctrl_trans::create::create_obj("[ GEN ITEM ]",this);
    item_sock = new();
    if( !dvv_res_db#(virtual clk_rst_if)::get_res_db("cr_if_0",vif) )
        $fatal();

    if( !dvv_res_db#(integer)::get_res_db("rep_number",repeat_n) )
        $fatal();

    $display("%s build complete", this.fname);
endtask : build

task tr_rgen::run();
    @(posedge vif.rstn);
    item_sock.wait_sock();
    repeat(repeat_n)
    begin
        item.make_tr();
        item_sock.send_msg(item);
        item_sock.wait_sock();
    end
    $stop;
endtask : run

`endif // TR_RGEN__SV
