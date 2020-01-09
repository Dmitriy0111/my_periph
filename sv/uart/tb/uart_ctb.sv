/* 
*  File            :   uart_ctb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.10
*  Language        :   SystemVerilog
*  Description     :   This is testbench for uart module
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`include "../rtl/uart.svh"
import uart_test_pkg::*;
import dvv_vm_pkg::*;

`define apb_con( apb_if_name    ) \
                .paddr      ( apb_if_name.paddr     ),  // apb address \
                .prdata     ( apb_if_name.prdata    ),  // apb read data \
                .pwdata     ( apb_if_name.pwdata    ),  // apb write data \
                .psel       ( apb_if_name.psel      ),  // apb select signal \
                .penable    ( apb_if_name.penable   ),  // apb enable signal \
                .pwrite     ( apb_if_name.pwrite    ),  // apb write signal \
                .pready     ( apb_if_name.pready    ),  // apb ready signal \
                .pslverr    ( apb_if_name.pslverr   )   // apb error signal
`define ahb_con( simple_if_name ) \
                .haddr      ( simple_if_name.haddr  ), // ahb address \
                .hrdata     ( simple_if_name.hrdata ), // ahb read data \
                .hwdata     ( simple_if_name.hwdata ), // ahb write data \
                .hwrite     ( simple_if_name.hwrite ), // ahb write signal \
                .htrans     ( simple_if_name.htrans ), // ahb transfer control signal \
                .hsize      ( simple_if_name.hsize  ), // ahb size signal \
                .hburst     ( simple_if_name.hburst ), // ahb burst signal \
                .hresp      ( simple_if_name.hresp  ), // ahb response signal \
                .hready     ( simple_if_name.hready ), // ahb ready signal \
                .hsel       ( simple_if_name.hsel   )  // ahb select signal
`define sif_con( simple_if_name ) \
                .addr       ( simple_if_name.addr   ), // address \
                .re         ( simple_if_name.re     ), // read enable \
                .we         ( simple_if_name.we     ), // write enable \
                .wd         ( simple_if_name.wd     ), // write data \
                .rd         ( simple_if_name.rd     )  // read data
`define avalon_con( avalon_if_name ) \
                .address    ( avalon_if_name.address    ), // avalon address \
                .readdata   ( avalon_if_name.readdata   ), // avalon read data \
                .writedata  ( avalon_if_name.writedata  ), // avalon write data \
                .write      ( avalon_if_name.write      ), // avalon write signal \
                .chipselect ( avalon_if_name.chipselect )  // avalon chip select signal

module uart_ctb();

    timeprecision       1ns;
    timeunit            1ns;

    parameter           T = 10,
                        start_del = 200,
                        rst_delay = 7,
                        repeat_n = 10,
                        if_name = "apb_if",
                        test_type = "direct_test";

    // reset and clock
    logic   [0  : 0]    clk;        // clk
    logic   [0  : 0]    rstn;       // reset

    uart_test           test;

    simple_if
    sif_0
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
        else if( if_name == "ahb_if" )
        begin : dut_gen
            uart_ahb
            dut
            (
                // clock and reset
                .hclk       ( clk               ),  // clock
                .hresetn    ( rstn              ),  // reset
                // bus side
                `ahb_con    ( ahb_if_0          ),
                // IRQ
                .irq        ( irq_if_0.irq      ),  // interrupt request
                // uart side
                .uart_tx    ( uif_0.uart_tx     ),  // UART tx wire
                .uart_rx    ( uif_0.uart_rx     )   // UART rx wire
            );
        end
        else if( if_name == "avalon_if" )
        begin : dut_gen
            uart_avalon
            dut
            (
                // clock and reset
                .clk        ( clk               ),  // clock
                .rstn       ( rstn              ),  // reset
                // bus side
                `avalon_con ( avalon_if_0       ),
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

        dvv_res_db#( virtual irq_if     )::set_res_db( "irq_if_0"    , irq_if_0    );
        dvv_res_db#( virtual clk_rst_if )::set_res_db( "cr_if_0"     , cr_if_0     );
        dvv_res_db#( virtual uart_if    )::set_res_db( "uif_0"       , uif_0       );

        case( if_name )
            "apb_if"    : dvv_res_db#( virtual apb_if     )::set_res_db( "apb_if_0"    , apb_if_0    );
            "ahb_if"    : dvv_res_db#( virtual ahb_if     )::set_res_db( "ahb_if_0"    , ahb_if_0    );
            "avalon_if" : dvv_res_db#( virtual avalon_if  )::set_res_db( "avalon_if_0" , avalon_if_0 );
            "simple_if" : dvv_res_db#( virtual simple_if  )::set_res_db( "sif_0"       , sif_0       );
        endcase
        
        dvv_res_db#(string)::set_res_db( "test_if"   , if_name   );
        dvv_res_db#(string)::set_res_db( "test_type" , test_type );
        
        dvv_res_db#(integer)::set_res_db( "rep_number" , repeat_n );

        case( test_type )
            "rand_test" :   
            begin
                automatic uart_rtest uart_rtest_ = new("[ UART RANDOM TEST ]", null);
                test = uart_rtest_;
            end
            "direct_test" :   
            begin
                automatic uart_dtest uart_dtest_ = new("[ UART DIRECT TEST ]", null);
                test = uart_dtest_;
            end
        endcase

        test.build();
        test.connect();
        test.run();
    end

endmodule : uart_ctb
