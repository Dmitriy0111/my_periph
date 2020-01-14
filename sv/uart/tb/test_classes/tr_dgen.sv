/*
*  File            :   tr_dgen.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is transaction direct generator 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef TR_DGEN__SV
`define TR_DGEN__SV

class tr_dgen extends tr_gen;
    `OBJ_BEGIN( tr_dgen )

    int     fp;

    extern function new(string name = "", dvv_bc parent = null);

    extern task build();
    extern task run();
    
endclass : tr_dgen

function tr_dgen::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task tr_dgen::build();
    item = ctrl_trans::create::create_obj("[ GEN ITEM ]",this);
    item_sock = new();

    if( !dvv_res_db#(virtual clk_rst_if)::get_res_db("cr_if_0",vif) )
        $fatal();

    fp = $fopen("../sv/uart/tb/test_classes/tr_dgen.dat", "r");
    if( fp == 0 )
        $fatal();
        
    $display("%s build complete", this.fname);
endtask : build

task tr_dgen::run();
    @(posedge vif.rstn);
    item_sock.wait_sock();

    for(;( $feof(fp) == '0 );)
    begin
        item.tr_num++;
        $fscanf(fp, "%h %d", item.data, item.freq);
        item_sock.send_msg(item);
        item_sock.wait_sock();
    end
    $stop;
endtask : run

`endif // TR_DGEN__SV
