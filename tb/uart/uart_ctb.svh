/* 
*  File            :   uart_ctb.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.10
*  Language        :   SystemVerilog
*  Description     :   This is testbench for uart module
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef UART_CTB__SVH
`define UART_CTB__SVH

`define dut_sif_con( dut_name, clk, rstn, ctrl_if, irq_if, uart_if ) \
    uart \
    dut_name \
    ( \
        // reset and clock \
        .clk        ( clk               ),  // clk \
        .rstn       ( rstn              ),  // reset \
        // simple interface \
        .addr       ( ctrl_if.addr      ),  // address \
        .re         ( ctrl_if.re        ),  // read enable \
        .we         ( ctrl_if.we        ),  // write enable \
        .wd         ( ctrl_if.wd        ),  // write data \
        .rd         ( ctrl_if.rd        ),  // read data \
        // IRQ \
        .irq        ( irq_if.irq        ),  // interrupt request \
        // uart side \
        .uart_tx    ( uart_if.uart_tx   ),  // UART tx wire \
        .uart_rx    ( uart_if.uart_rx   )   // UART rx wire \
    ); \
                
`define dut_ahb_con( dut_name, clk, rstn, ctrl_if, irq_if, uart_if ) \
    uart_ahb \
    dut_name \
    ( \
        // clock and reset \
        .hclk       ( clk               ),  // clock \
        .hresetn    ( rstn              ),  // reset \
        // bus side \
        .haddr      ( ctrl_if.haddr     ),  // ahb address \
        .hrdata     ( ctrl_if.hrdata    ),  // ahb read data \
        .hwdata     ( ctrl_if.hwdata    ),  // ahb write data \
        .hwrite     ( ctrl_if.hwrite    ),  // ahb write signal \
        .htrans     ( ctrl_if.htrans    ),  // ahb transfer control signal \
        .hsize      ( ctrl_if.hsize     ),  // ahb size signal \
        .hburst     ( ctrl_if.hburst    ),  // ahb burst signal \
        .hresp      ( ctrl_if.hresp     ),  // ahb response signal \
        .hready     ( ctrl_if.hready    ),  // ahb ready signal \
        .hsel       ( ctrl_if.hsel      ),  // ahb select signal \
        // IRQ \
        .irq        ( irq_if.irq        ),  // interrupt request \
        // uart side \
        .uart_tx    ( uart_if.uart_tx   ),  // UART tx wire \
        .uart_rx    ( uart_if.uart_rx   )   // UART rx wire \
    ); \
                
`define dut_apb_con( dut_name, clk, rstn, ctrl_if, irq_if, uart_if ) \
    uart_apb \
    dut_name \
    ( \
        // clock and reset \
        .pclk       ( clk               ),  // apb clock \
        .presetn    ( rstn              ),  // apb reset \
        // bus side \
        .paddr      ( ctrl_if.paddr     ),  // apb address \
        .prdata     ( ctrl_if.prdata    ),  // apb read data \
        .pwdata     ( ctrl_if.pwdata    ),  // apb write data \
        .psel       ( ctrl_if.psel      ),  // apb select signal \
        .penable    ( ctrl_if.penable   ),  // apb enable signal \
        .pwrite     ( ctrl_if.pwrite    ),  // apb write signal \
        .pready     ( ctrl_if.pready    ),  // apb ready signal \
        .pslverr    ( ctrl_if.pslverr   ),  // apb error signal \
        // IRQ \
        .irq        ( irq_if.irq        ),  // interrupt request \
        // uart side \
        .uart_tx    ( uart_if.uart_tx   ),  // UART tx wire \
        .uart_rx    ( uart_if.uart_rx   )   // UART rx wire \
    ); \
                
`define dut_avalon_con( dut_name, clk, rstn, ctrl_if, irq_if, uart_if ) \
    uart_avalon \
    dut_name \
    ( \
        // clock and reset \
        .clk        ( clk                   ),  // clock \
        .rstn       ( rstn                  ),  // reset \
        // bus side \
        .address    ( ctrl_if.address       ),  // avalon address \
        .readdata   ( ctrl_if.readdata      ),  // avalon read data \
        .writedata  ( ctrl_if.writedata     ),  // avalon write data \
        .write      ( ctrl_if.write         ),  // avalon write signal \
        .chipselect ( ctrl_if.chipselect    ),  // avalon chip select signal \
        // IRQ \
        .irq        ( irq_if.irq            ),  // interrupt request \
        // uart side \
        .uart_tx    ( uart_if.uart_tx       ),  // UART tx wire \
        .uart_rx    ( uart_if.uart_rx       )   // UART rx wire \
    ); \

`endif // UART_CTB__SVH
