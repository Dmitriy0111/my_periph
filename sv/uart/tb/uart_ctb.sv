/* 
*  File            :   uart_ctb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.10
*  Language        :   SystemVerilog
*  Description     :   This is testbench for uart module
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`include "../rtl/uart.svh"
`include "uart_ctb.svh"
import uart_test_pkg::*;
import dvv_vm_pkg::*;

module uart_ctb();

    timeprecision       1ns;
    timeunit            1ns;

    parameter           T = 10,
                        start_del = 200,
                        rst_delay = 7,
                        repeat_n = 40,
                        if_name = "sif_if",
                        test_type = "direct_test";

    // reset and clock
    logic   [0  : 0]    clk;        // clk
    logic   [0  : 0]    rstn;       // reset

    uart_test           test;

    simple_if
    sif_if_0
    (
        .clk        ( clk           ),
        .rstn       ( rstn          )
    );

    avalon_if
    avalon_if_0
    (
        .clk        ( clk           ),
        .rstn       ( rstn          )
    );

    irq_if
    irq_if_0
    (
        .clk        ( clk           ),
        .rstn       ( rstn          )
    );

    apb_if
    apb_if_0
    (
        .pclk       ( clk           ),
        .presetn    ( rstn          )
    );

    ahb_if
    ahb_if_0
    (
        .hclk       ( clk           ),
        .hresetn    ( rstn          )
    );

    clk_rst_if
    cr_if_0
    (
        .clk        ( clk           ),
        .rstn       ( rstn          )
    );

    uart_if
    uif_0
    (
        .clk        ( clk           ),
        .rstn       ( rstn          )
    );

    assign uart_rx = '0;

    generate
        case( if_name )
            "sif_if"    : begin : dut_gen `dut_sif_con      ( dut , clk , rstn , sif_if_0    , irq_if_0 , uif_0 ) end
            "apb_if"    : begin : dut_gen `dut_apb_con      ( dut , clk , rstn , apb_if_0    , irq_if_0 , uif_0 ) end
            "ahb_if"    : begin : dut_gen `dut_ahb_con      ( dut , clk , rstn , ahb_if_0    , irq_if_0 , uif_0 ) end
            "avalon_if" : begin : dut_gen `dut_avalon_con   ( dut , clk , rstn , avalon_if_0 , irq_if_0 , uif_0 ) end
            default     : $fatal("DUT doesn't created");
        endcase
    endgenerate
    
    initial
    begin
        # start_del;
        clk = '0;
        forever
            #(T/2) clk = ! clk;
    end

    initial
    begin
        # start_del;
        rstn = '0;
        repeat(rst_delay) @(posedge clk);
        rstn = '1;
    end

    initial
    begin
        # start_del;

        dvv_res_db#( virtual irq_if     )::set_res_db( "irq_if_0"    , irq_if_0    );
        dvv_res_db#( virtual clk_rst_if )::set_res_db( "cr_if_0"     , cr_if_0     );
        dvv_res_db#( virtual uart_if    )::set_res_db( "uif_0"       , uif_0       );

        case( if_name )
            "apb_if"    : dvv_res_db#( virtual apb_if     )::set_res_db( "apb_if_0"    , apb_if_0    );
            "ahb_if"    : dvv_res_db#( virtual ahb_if     )::set_res_db( "ahb_if_0"    , ahb_if_0    );
            "avalon_if" : dvv_res_db#( virtual avalon_if  )::set_res_db( "avalon_if_0" , avalon_if_0 );
            "sif_if"    : dvv_res_db#( virtual simple_if  )::set_res_db( "sif_if_0"    , sif_if_0    );
        endcase
        
        dvv_res_db#(string)::set_res_db( "test_if"   , if_name   );
        dvv_res_db#(string)::set_res_db( "test_type" , test_type );
        
        dvv_res_db#(integer)::set_res_db( "rep_number" , repeat_n );

        case( test_type )
            "rand_test" :   
            begin
                automatic uart_rtest uart_rtest_ = new("uart_random_test", null);
                test = uart_rtest_;
            end
            "direct_test" :   
            begin
                automatic uart_dtest uart_dtest_ = new("uart_direct_test", null);
                test = uart_dtest_;
            end
        endcase

        test.test_start();
    end

endmodule : uart_ctb
