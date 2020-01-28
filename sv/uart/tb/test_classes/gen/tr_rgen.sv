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

    ctrl_trans                  resp_item;

    uart_struct                 uart_p = new_uart(0,0);

    extern function new(string name = "", dvv_bc parent = null);

    extern task build();
    extern task run();
    
endclass : tr_rgen

function tr_rgen::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
    u_agt_aep = new("u_agt_aep");
    scb_aep = new("scb_aep");
endfunction : new

task tr_rgen::build();
    item = new("gen_item",this);
    resp_item = new("gen_resp_item",this);

    item_sock = new();
    resp_sock = new();

    if( !dvv_res_db#(virtual clk_rst_if)::get_res_db("cr_if_0",vif) )
        $fatal();

    if( !dvv_res_db#(virtual irq_if)::get_res_db("irq_if_0",irq_vif) )
        $fatal();

    if( !dvv_res_db#(integer)::get_res_db("rep_number",repeat_n) )
        $fatal();
endtask : build

task tr_rgen::run();
    fork
        begin
            @(posedge vif.rstn);

            repeat(repeat_n)
            begin
                randsequence (rand_seq)
                    rand_seq        : set_cr set_irq_m set_dfr set_tr_data wait_tr;
                    set_cr          :
                    {
                        if( | uart_p.cr_c.data[1 : 0] )
                            return;
                        else
                        begin
                            uart_p.cr_c.data.tr_en = '1;
                            item.set_addr( uart_p.cr_c.addr );
                            item.set_data( uart_p.cr_c.data );
                            item.set_we_re( '1 );
                            item_sock.send_msg(item);
                            item_sock.wait_sock();
                            print("set_cr\n");
                        end
                    };
                    set_irq_m       :
                    {   
                        if( $urandom_range(0,1) )
                        begin
                            print("set_irq_m_1\n");
                            if( ! uart_p.irq_m_c.data[0] )
                            begin
                                uart_p.irq_m_c.data[0] = '1;
                                item.set_addr( uart_p.irq_m_c.addr );
                                item.set_data( uart_p.irq_m_c.data );
                                item.set_we_re( '1 );
                                item_sock.send_msg(item);
                                item_sock.wait_sock();
                            end
                        end
                        else
                        begin
                            print("set_irq_m_0\n");
                            if(   uart_p.irq_m_c.data[0] )
                            begin
                                uart_p.irq_m_c.data[0] = '0;
                                item.set_addr( uart_p.irq_m_c.addr );
                                item.set_data( uart_p.irq_m_c.data );
                                item.set_we_re( '1 );
                                item_sock.send_msg(item);
                                item_sock.wait_sock();
                            end
                        end
                    };
                    set_dfr         :   
                    { 
                        if( ( ( $urandom_range(0,1) == 0 ) && ( uart_p.dfr_c.data != 0 ) ) ) 
                            return; 
                        item.data_tr_c.constraint_mode(0); 
                        item.data_freq_c.constraint_mode(1); 
                        item.make_tr();
                        item.set_addr( 32'h8 );
                        item.set_we_re( '1 );
                        u_agt_aep.write(item.get_data());
                        item_sock.send_msg(item);
                        item_sock.wait_sock();
                        print("set_dfr\n");
                    };
                    set_tr_data     : 
                    { 
                        item.data_tr_c.constraint_mode(1); 
                        item.data_freq_c.constraint_mode(0); 
                        item.make_tr();
                        item.set_addr( 32'h4 );
                        item.set_we_re( '1 );
                        scb_aep.write(item.get_data());
                        item_sock.send_msg(item);
                        item_sock.wait_sock();
                        print("set_tr_data\n");
                    };
                    wait_tr         :
                        if( uart_p.irq_m_c.data[0] )
                            wait_tr_irq
                        else
                            wait_tr_done;
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
                                resp_sock.rec_msg(resp_item);
                                item_sock.wait_sock();
                            join
                            if( ! ( resp_item.get_data() & 32'h4 ) )
                            break;
                        end
                        print("wait_tr_done\n");
                    };
                    wait_tr_irq     : 
                    { 
                        @(posedge irq_vif.irq);//wait(irq_vif.irq == 1'b0);
                        item.set_addr( uart_p.irq_v_c.addr );
                        item.set_data( '0 );
                        item.set_we_re( '0 );
                        item_sock.send_msg(item);
                        fork
                            resp_sock.rec_msg(resp_item);
                            item_sock.wait_sock();
                        join
                        item.set_data(resp_item.get_data() & (~32'h1));
                        item.set_addr( uart_p.irq_v_c.addr );
                        item.set_data( '0 );
                        item.set_we_re( '1 );
                        item_sock.send_msg(item);
                        item_sock.wait_sock();
                        print("wait_tr_irq\n");
                    };
                endsequence
            end
            $stop;
        end
    join_none
endtask : run

`endif // TR_RGEN__SV
