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

    integer                     repeat_n;

    extern function new(string name = "", dvv_bc parent = null);

    extern task build();
    extern task run();
    
endclass : tr_rgen

function tr_rgen::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
    u_agt_aep = new();
    $display();
endfunction : new

task tr_rgen::build();
    item = ctrl_trans::create::create_obj("[ GEN ITEM ]",this);

    item_sock = new();
    resp_sock = new();

    if( !dvv_res_db#(virtual clk_rst_if)::get_res_db("cr_if_0",vif) )
        $fatal();

    if( !dvv_res_db#(integer)::get_res_db("rep_number",repeat_n) )
        $fatal();

    $display("%s build complete", this.fname);
endtask : build

task tr_rgen::run();
    @(posedge vif.rstn);

    item.set_addr( 32'h0 );
    item.set_data( 32'h01 );
    item.set_we_re( '1 );
    item.tr_num++;
    item_sock.send_msg(item);
    item.print();
    item_sock.wait_sock();

    item.set_addr( 32'h8 );
    item.set_data( 32'h28 );
    item.set_we_re( '1 );
    item.tr_num++;
    item_sock.send_msg(item);
    item.print();
    item_sock.wait_sock();

    repeat(repeat_n)
    begin
        randsequence (rand_seq)
            rand_seq        : set_dfr set_tr_data wait_tr_done;
            set_dfr         :   
            { 
                if( ! $urandom_range(0,1) ) return; 
                item.data_tr_c.constraint_mode(0); 
                item.data_freq_c.constraint_mode(1); 
                item.make_tr();
                item.set_addr( 32'h8 );
                item.set_we_re( '1 );
                u_agt_aep.write(item.get_data());
                item_sock.send_msg(item);
                item.print();
                item_sock.wait_sock();
                $display("set_dfr");
            };
            set_tr_data     : 
            { 
                item.data_tr_c.constraint_mode(1); 
                item.data_freq_c.constraint_mode(0); 
                item.make_tr();
                item.set_addr( 32'h4 );
                item.set_we_re( '1 );
                item_sock.send_msg(item);
                item.print();
                item_sock.wait_sock();
                $display("set_tr_data"); 
            };
            wait_tr_done    : 
            { 
                for(;;)
                begin
                    item.set_addr( 32'h0 );
                    item.set_data( '0 );
                    item.set_we_re( '0 );
                    item.tr_num++;
                    item_sock.send_msg(item);
                    fork
                        resp_sock.rec_msg(item);
                        item_sock.wait_sock();
                    join
                    if( ! ( item.get_data() & 32'h4 ) )
                    break;
                end
                $display("wait_tr_done"); 
            };
        endsequence
    end
    $stop;
endtask : run

`endif // TR_RGEN__SV
