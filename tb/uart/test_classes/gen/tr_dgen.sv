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

    int                     fp;
    string                  msg = "Hello World!";

    bit         [31 : 0]    addr;
    bit         [31 : 0]    data;
    string                  cmd;

    ctrl_trans              resp_item;

    extern function new(string name = "", dvv_bc parent = null);

    extern task build();
    extern task run();
    
endclass : tr_dgen

function tr_dgen::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
    u_agt_aep = new();
    scb_aep = new();
endfunction : new

task tr_dgen::build();
    item = new("gen_item",this);
    resp_item = new("gen_resp_item",this);

    item_sock = new();
    resp_sock = new();

    if( !dvv_res_db#(virtual clk_rst_if)::get_res_db("cr_if_0",vif) )
        $fatal();

    fp = $fopen("../sv/uart/tb/test_classes/tr_dgen.dat", "r");
    if( fp == 0 )
        $fatal();
endtask : build

task tr_dgen::run();
    fork
        begin
            @(posedge vif.rstn);
            
            item.set_addr( 32'h0 );
            item.set_data( 32'h01 );
            item.set_we_re( '1 );
            item.tr_num++;
            item_sock.send_msg(item);
            item_sock.wait_sock();
            
            item.set_addr( 32'h8 );
            item.set_data( 32'h28 );
            item.set_we_re( '1 );
            item.tr_num++;
            item_sock.send_msg(item);
            item_sock.wait_sock();
            
            for(; !$feof(fp) ;)
            begin
                $fscanf(fp,"%s %h %h", cmd, addr, data);
                if( addr == 32'h8 )
                u_agt_aep.write(data);
                item.set_addr(addr);
                item.set_data(data);
                item.set_we_re( ( cmd == "WR" ? '1 : '0 ) );
                if( cmd == "WR" )
                begin
                    item_sock.send_msg(item);
                    if(item.get_addr() == 32'h4)
                    scb_aep.write(item.get_data());
                    item_sock.wait_sock();
                end
                else
                begin
                    for(;;)
                    begin
                        item_sock.send_msg(item);
                        fork
                            resp_sock.rec_msg(resp_item);
                            item_sock.wait_sock();
                        join
                        if( ! ( resp_item.get_data() & 32'h4 ) )
                        break;
                    end
                end
            end
            $stop;
        end
    join_none
endtask : run

`endif // TR_DGEN__SV
