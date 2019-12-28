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

`define apb_con( apb_if_name    ) \
                .paddr      ( apb_if_name.paddr     ),  // apb slave address \
                .prdata     ( apb_if_name.prdata    ),  // apb slave read data \
                .pwdata     ( apb_if_name.pwdata    ),  // apb slave write data \
                .psel       ( apb_if_name.psel      ),  // apb slave select signal \
                .penable    ( apb_if_name.penable   ),  // apb slave enable signal \
                .pwrite     ( apb_if_name.pwrite    ),  // apb slave write signal \
                .pready     ( apb_if_name.pready    ),  // apb slave ready signal \
                .pslverr    ( apb_if_name.pslverr   )   // apb slave error signal
`define sif_con( simple_if_name ) \
                .addr       ( simple_if_name.addr   ), // address \
                .re         ( simple_if_name.re     ), // read enable \
                .we         ( simple_if_name.we     ), // write enable \
                .wd         ( simple_if_name.wd     ), // write data \
                .rd         ( simple_if_name.rd     )  // read data

`define sel_con( if_name        ) ( if_name[if_name.size-2 : 0] == "apb_if" ) ? `apb_con( if_name ) : `sif_con( if_name )

module uart_ctb();

    timeprecision       1ns;
    timeunit            1ns;

    parameter           T = 10,
                        start_del = 200,
                        rst_delay = 7,
                        repeat_n = 200,
                        if_name = "apb_if";

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
        if( if_name == "simple_if" )
        begin : dut_gen
            uart
            dut
            (
                // reset and clock
                .clk        ( clk           ),  // clk
                .rstn       ( rstn          ),  // reset
                // simple interface
                `sif_con    ( sif_0         ),
                // IRQ
                .irq        ( irq_if_0.irq  ),  // interrupt request
                // uart side
                .uart_tx    ( uif_0.uart_tx ),  // UART tx wire
                .uart_rx    ( uif_0.uart_rx )   // UART rx wire
            );
        end
        else if( if_name == "apb_if" )
        begin : dut_gen
            uart_apb
            dut
            (
                // clock and reset
                .pclk       ( clk               ),  // apb clock
                .presetn    ( rstn              ),  // apb reset
                // bus side
                `apb_con    ( apb_if_0          ),
                // IRQ
                .irq        ( irq_if_0.irq      ),  // interrupt request
                // uart side
                .uart_tx    ( uif_0.uart_tx     ),  // UART tx wire
                .uart_rx    ( uif_0.uart_rx     )   // UART rx wire
            );
        end
    endgenerate
    

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
        dvv_res_db#(virtual irq_if)::set_res_db("irq_if_0",irq_if_0);
        dvv_res_db#(virtual apb_if)::set_res_db("apb_if_0",apb_if_0);
        dvv_res_db#(virtual clk_rst_if)::set_res_db("cr_if_0",cr_if_0);
        dvv_res_db#(virtual uart_if)::set_res_db("uif_0",uif_0);

        dvv_res_db#(string)::set_res_db("test_if",if_name);

        test.build();
        test.connect();
        test.run();
    end

endmodule : uart_ctb
