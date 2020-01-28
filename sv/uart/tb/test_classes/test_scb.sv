/*
*  File            :   test_scb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.17
*  Language        :   SystemVerilog
*  Description     :   This is test scoreboard 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef TEST_SCB__SV
`define TEST_SCB__SV

`dvv_ap_decl(_ctrl)
`dvv_ap_decl(_uart)

class test_scb extends dvv_scb;
    `OBJ_BEGIN( test_scb )

    typedef test_scb test_scb_t;

    dvv_ap_ctrl     #(int,test_scb_t)   ctrl_ap;
    dvv_ap_uart     #(int,test_scb_t)   uart_ap;

    logic   [7 : 0]     ctrl_q [$];
    logic   [7 : 0]     uart_q [$];

    string              msg;

    extern function new(string name = "", dvv_bc parent = null);

    extern function void write_ctrl(int item);
    extern function void write_uart(int item);

    extern task build();
    extern task run();
    
endclass : test_scb

function test_scb::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
    ctrl_ap = new(this,"ctrl_ap");
    uart_ap = new(this,"uart_ap");
endfunction : new

function void test_scb::write_ctrl(int item);
    ctrl_q.push_back(item);
endfunction : write_ctrl

function void test_scb::write_uart(int item);
    uart_q.push_back(item);
endfunction : write_uart

task test_scb::build();
endtask : build

task test_scb::run();
    fork
        forever
        begin
            wait( (ctrl_q.size() != 0 ) && ( uart_q.size() != 0 ) );
            if( ctrl_q[0] == uart_q[0] )
            begin
                $swrite(msg, "TEST PASS %h %h\n", ctrl_q.pop_front(), uart_q.pop_front());
                print(msg);
            end
            else
            begin
                $swrite(msg, "TEST FAIL %h %h\n", ctrl_q.pop_front(), uart_q.pop_front());
                print(msg);
            end
        end
    join_none
endtask : run

`endif // TEST_SCB__SV
