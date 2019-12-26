/* 
*  File            :   uart_ctb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.10
*  Language        :   SystemVerilog
*  Description     :   This is testbench for uart module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "../rtl/uart.svh"
import uart_test_pkg::*;
import dvv_vm_pkg::*;

module uart_ctb();

    timeprecision       1ns;
    timeunit            1ns;

    parameter           T = 10,
                        start_del = 200,
                        rst_delay = 7,
                        repeat_n = 200;

    // reset and clock
    logic   [0  : 0]    clk;        // clk
    logic   [0  : 0]    rstn;       // reset

    uart_dtest          test;

    simple_if
    sif_0
    (
        .clk        ( clk           ),
        .rstn       ( rstn          )
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

    uart
    dut
    (
        // reset and clock
        .clk        ( clk           ),  // clk
        .rstn       ( rstn          ),  // reset
        // simple interface
        .addr       ( sif_0.addr    ),  // address
        .re         ( sif_0.re      ),  // read enable
        .we         ( sif_0.we      ),  // write enable
        .wd         ( sif_0.wd      ),  // write data
        .rd         ( sif_0.rd      ),  // read data
        // IRQ
        .irq        ( sif_0.irq     ),  // interrupt request
        // uart side
        .uart_tx    ( uif_0.uart_tx ),  // UART tx wire
        .uart_rx    ( uif_0.uart_rx )   // UART rx wire
    );

    initial
    begin
        # start_del;
        clk = '0;
        forever
            #(T/2) clk <= !clk;
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
        
        test = new("[ RAND_TEST ]",null);
        dvv_res_db#(virtual simple_if)::set_res_db("sif_0",sif_0);
        dvv_res_db#(virtual clk_rst_if)::set_res_db("cr_if_0",cr_if_0);
        dvv_res_db#(virtual uart_if)::set_res_db("uif_0",uif_0);

        test.build();
        test.connect();
        test.run();
    end

endmodule : uart_ctb
