/* 
*  File            :   ahb_apb_test_system_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.23
*  Language        :   SystemVerilog
*  Description     :   This ahb, apb system testbench
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "../../gpio/rtl/gpio.svh"

module ahb_apb_test_system_tb();

    timeprecision                       1ns;
    timeunit                            1ns;

    parameter               a_w = 20,
                            cdc_use = 1,
                            ahb_slv_c = 5,
                            apb_slv_c = 4,
                            gpio_w = 8,
                            cs_w = 8,
                            tmr_w = 8;

    parameter               T = 10,
                            Tp = (cdc_use == 1) ? T*7 : T,
                            start_del = 200,
                            rst_delay = 7,
                            repeat_n = 2000;

    // clock and reset
    logic   [0  : 0]   hclk;       // ahb clock
    logic   [0  : 0]   hresetn;    // ahb reset
    logic   [0  : 0]   pclk;       // apb clock
    logic   [0  : 0]   presetn;    // apb reset
    // ahb router signals
    // Master side
    logic   [ahb_slv_c-1 : 0][31 : 0]   haddr_am;   // ahb master address mask
    logic                    [31 : 0]   haddr;      // ahb master address
    logic                    [31 : 0]   hrdata;     // ahb master read data
    logic                    [31 : 0]   hwdata;     // ahb master write data
    logic                    [0  : 0]   hwrite;     // ahb master write signal
    logic                    [1  : 0]   htrans;     // ahb master transfer control signal
    logic                    [2  : 0]   hsize;      // ahb master size signal
    logic                    [2  : 0]   hburst;     // ahb master burst signal
    logic                    [1  : 0]   hresp;      // ahb master response signal
    logic                    [0  : 0]   hready;     // ahb master ready signal
    // Slaves side
    logic   [ahb_slv_c-1 : 0][31 : 0]   haddr_s;    // ahb slave address
    logic   [ahb_slv_c-1 : 0][31 : 0]   hrdata_s;   // ahb slave read data
    logic   [ahb_slv_c-1 : 0][31 : 0]   hwdata_s;   // ahb slave write data
    logic   [ahb_slv_c-1 : 0][0  : 0]   hwrite_s;   // ahb slave write signal
    logic   [ahb_slv_c-1 : 0][1  : 0]   htrans_s;   // ahb slave transfer control signal
    logic   [ahb_slv_c-1 : 0][2  : 0]   hsize_s;    // ahb slave size signal
    logic   [ahb_slv_c-1 : 0][2  : 0]   hburst_s;   // ahb slave burst signal
    logic   [ahb_slv_c-1 : 0][1  : 0]   hresp_s;    // ahb slave response signal
    logic   [ahb_slv_c-1 : 0][0  : 0]   hready_s;   // ahb slave ready signal
    logic   [ahb_slv_c-1 : 0][0  : 0]   hsel_s;     // ahb slave select signal
    // apb router signals
    // APB master side
    logic   [apb_slv_c-1 : 0][a_w-1 : 0]    paddr_am;   // apb master address mask
    logic                    [a_w-1 : 0]    paddr;      // apb master address
    logic                    [31    : 0]    prdata;     // apb master read data
    logic                    [31    : 0]    pwdata;     // apb master write data
    logic                    [0     : 0]    psel;       // apb master select
    logic                    [0     : 0]    pwrite;     // apb master write
    logic                    [0     : 0]    penable;    // apb master enable
    logic                    [0     : 0]    pready;     // apb master ready
    // APB slave side
    logic   [apb_slv_c-1 : 0][a_w-1 : 0]    paddr_s;    // apb slave address
    logic   [apb_slv_c-1 : 0][31    : 0]    prdata_s;   // apb slave read data
    logic   [apb_slv_c-1 : 0][31    : 0]    pwdata_s;   // apb slave write data
    logic   [apb_slv_c-1 : 0][0     : 0]    psel_s;     // apb slave select
    logic   [apb_slv_c-1 : 0][0     : 0]    pwrite_s;   // apb slave write
    logic   [apb_slv_c-1 : 0][0     : 0]    penable_s;  // apb slave enable
    logic   [apb_slv_c-1 : 0][0     : 0]    pready_s;   // apb slave ready

    // AHB periph
    // TMR
    logic   [0        : 0]  h_tmr_irq;
    logic   [0        : 0]  h_tmr_in;
    logic   [0        : 0]  h_tmr_out;
    // SPI
    logic   [0        : 0]  h_spi_irq;  // interrupt request
    logic   [0        : 0]  h_spi_mosi; // SPI mosi wire
    logic   [0        : 0]  h_spi_miso; // SPI miso wire
    logic   [0        : 0]  h_spi_sck;  // SPI sck wire
    logic   [cs_w-1   : 0]  h_spi_cs;   // SPI cs wire
    // UART
    logic   [0        : 0]  h_uart_irq; // interrupt request
    logic   [0        : 0]  h_uart_tx;  // UART tx wire
    logic   [0        : 0]  h_uart_rx;  // UART rx wire
    // GPIO
    logic   [0        : 0]  h_gpi_irq;
    logic   [gpio_w-1 : 0]  h_gpi;
    logic   [gpio_w-1 : 0]  h_gpo;
    logic   [gpio_w-1 : 0]  h_gpd;
    // APB periph
    // TMR
    logic   [0        : 0]  p_tmr_irq;
    logic   [0        : 0]  p_tmr_in;
    logic   [0        : 0]  p_tmr_out;
    // SPI
    logic   [0        : 0]  p_spi_irq;  // interrupt request
    logic   [0        : 0]  p_spi_mosi; // SPI mosi wire
    logic   [0        : 0]  p_spi_miso; // SPI miso wire
    logic   [0        : 0]  p_spi_sck;  // SPI sck wire
    logic   [cs_w-1   : 0]  p_spi_cs;   // SPI cs wire
    // UART
    logic   [0        : 0]  p_uart_irq; // interrupt request
    logic   [0        : 0]  p_uart_tx;  // UART tx wire
    logic   [0        : 0]  p_uart_rx;  // UART rx wire
    // GPIO
    logic   [0        : 0]  p_gpi_irq;
    logic   [gpio_w-1 : 0]  p_gpi;
    logic   [gpio_w-1 : 0]  p_gpo;
    logic   [gpio_w-1 : 0]  p_gpd;

    logic   [31    : 0]     slv [2**a_w-1];

    integer                 addr_q  [$];
    logic   [31    : 0]     data_wq [integer];
    logic   [31    : 0]     data_rq [integer];

    assign haddr_am =   
                        { 
                            { 32'h0004_XXXX },
                            { 32'h0003_XXXX },
                            { 32'h0002_XXXX },
                            { 32'h0001_XXXX },
                            { 32'h0000_XXXX }
                        };

    assign paddr_am = 
                        { 
                            { 20'h0000_03XX },
                            { 20'h0000_02XX },
                            { 20'h0000_01XX },
                            { 20'h0000_00XX }
                        };

    ahb_router
    #(
        .slv_c      ( ahb_slv_c     )
    )
    ahb_router_0
    (
        // clock and reset
        .hclk       ( hclk          ),  // ahb clock
        .hresetn    ( hresetn       ),  // ahb reset
        // Master side
        .haddr_am   ( haddr_am      ),  // ahb master address mask
        .haddr      ( haddr         ),  // ahb master address
        .hrdata     ( hrdata        ),  // ahb master read data
        .hwdata     ( hwdata        ),  // ahb master write data
        .hwrite     ( hwrite        ),  // ahb master write signal
        .htrans     ( htrans        ),  // ahb master transfer control signal
        .hsize      ( hsize         ),  // ahb master size signal
        .hburst     ( hburst        ),  // ahb master burst signal
        .hresp      ( hresp         ),  // ahb master response signal
        .hready     ( hready        ),  // ahb master ready signal
        // Slaves side
        .haddr_s    ( haddr_s       ),  // ahb slave address
        .hrdata_s   ( hrdata_s      ),  // ahb slave read data
        .hwdata_s   ( hwdata_s      ),  // ahb slave write data
        .hwrite_s   ( hwrite_s      ),  // ahb slave write signal
        .htrans_s   ( htrans_s      ),  // ahb slave transfer control signal
        .hsize_s    ( hsize_s       ),  // ahb slave size signal
        .hburst_s   ( hburst_s      ),  // ahb slave burst signal
        .hresp_s    ( hresp_s       ),  // ahb slave response signal
        .hready_s   ( hready_s      ),  // ahb slave ready signal
        .hsel_s     ( hsel_s        )   // ahb slave select signal
    );

    gpio_ahb
    #(
        .gpio_w     ( gpio_w        )
    )
    gpio_ahb_0
    (
        // clock and reset
        .hclk       ( hclk          ),  // ahb clock
        .hresetn    ( hresetn       ),  // ahb reset
        // bus side
        .haddr      ( haddr_s   [0] ),  // ahb slave address
        .hrdata     ( hrdata_s  [0] ),  // ahb slave read data
        .hwdata     ( hwdata_s  [0] ),  // ahb slave write data
        .hwrite     ( hwrite_s  [0] ),  // ahb slave write signal
        .htrans     ( htrans_s  [0] ),  // ahb slave transfer control signal
        .hsize      ( hsize_s   [0] ),  // ahb slave size signal
        .hburst     ( hburst_s  [0] ),  // ahb slave burst signal
        .hresp      ( hresp_s   [0] ),  // ahb slave response signal
        .hready     ( hready_s  [0] ),  // ahb slave ready signal
        .hsel       ( hsel_s    [0] ),  // ahb slave select signal
        // IRQ
        .irq        ( h_gpi_irq     ),  // interrupt request
        // GPIO side
        .gpi        ( h_gpi         ),  // GPIO input
        .gpo        ( h_gpo         ),  // GPIO output
        .gpd        ( h_gpd         )   // GPIO direction
    );

    uart_ahb
    uart_ahb_0
    (
        // clock and reset
        .hclk       ( hclk          ),  // ahb clock
        .hresetn    ( hresetn       ),  // ahb reset
        // bus side
        .haddr      ( haddr_s   [1] ),  // ahb slave address
        .hrdata     ( hrdata_s  [1] ),  // ahb slave read data
        .hwdata     ( hwdata_s  [1] ),  // ahb slave write data
        .hwrite     ( hwrite_s  [1] ),  // ahb slave write signal
        .htrans     ( htrans_s  [1] ),  // ahb slave transfer control signal
        .hsize      ( hsize_s   [1] ),  // ahb slave size signal
        .hburst     ( hburst_s  [1] ),  // ahb slave burst signal
        .hresp      ( hresp_s   [1] ),  // ahb slave response signal
        .hready     ( hready_s  [1] ),  // ahb slave ready signal
        .hsel       ( hsel_s    [1] ),  // ahb slave select signal
        // IRQ
        .irq        ( h_uart_irq    ),  // interrupt request
        // UART side
        .uart_tx    ( h_uart_tx     ),  // UART tx wire
        .uart_rx    ( h_uart_rx     )   // UART rx wire
    );

    tmr_ahb
    #(
        .tmr_w      ( tmr_w         )
    )
    tmr_ahb_0
    (
        // clock and reset
        .hclk       ( hclk          ),  // ahb clock
        .hresetn    ( hresetn       ),  // ahb reset
        // bus side
        .haddr      ( haddr_s   [2] ),  // ahb slave address
        .hrdata     ( hrdata_s  [2] ),  // ahb slave read data
        .hwdata     ( hwdata_s  [2] ),  // ahb slave write data
        .hwrite     ( hwrite_s  [2] ),  // ahb slave write signal
        .htrans     ( htrans_s  [2] ),  // ahb slave transfer control signal
        .hsize      ( hsize_s   [2] ),  // ahb slave size signal
        .hburst     ( hburst_s  [2] ),  // ahb slave burst signal
        .hresp      ( hresp_s   [2] ),  // ahb slave response signal
        .hready     ( hready_s  [2] ),  // ahb slave ready signal
        .hsel       ( hsel_s    [2] ),  // ahb slave select signal
        // IRQ
        .irq        ( h_tmr_irq     ),  // interrupt request
        // TMR side
        .tmr_in     ( h_tmr_in      ),  // TMR input
        .tmr_out    ( h_tmr_out     )   // TMR output
    );

    spi_ahb
    #(
        .cs_w       ( cs_w          )
    )
    spi_ahb_0
    (
        // clock and reset
        .hclk       ( hclk          ),  // ahb clock
        .hresetn    ( hresetn       ),  // ahb reset
        // bus side
        .haddr      ( haddr_s   [3] ),  // ahb slave address
        .hrdata     ( hrdata_s  [3] ),  // ahb slave read data
        .hwdata     ( hwdata_s  [3] ),  // ahb slave write data
        .hwrite     ( hwrite_s  [3] ),  // ahb slave write signal
        .htrans     ( htrans_s  [3] ),  // ahb slave transfer control signal
        .hsize      ( hsize_s   [3] ),  // ahb slave size signal
        .hburst     ( hburst_s  [3] ),  // ahb slave burst signal
        .hresp      ( hresp_s   [3] ),  // ahb slave response signal
        .hready     ( hready_s  [3] ),  // ahb slave ready signal
        .hsel       ( hsel_s    [3] ),  // ahb slave select signal
        // IRQ
        .irq        ( h_spi_irq     ),  // interrupt request
        // SPI side
        .spi_mosi   ( h_spi_mosi    ),  // SPI mosi wire
        .spi_miso   ( h_spi_miso    ),  // SPI miso wire
        .spi_sck    ( h_spi_sck     ),  // SPI sck wire
        .spi_cs     ( h_spi_cs      )   // SPI cs wire
    );

    ahb2apb_bridge
    #(
        .a_w        ( a_w           ),
        .cdc_use    ( cdc_use       )
    )
    ahb2apb_bridge_0
    (
        // AHB clock and reset
        .hclk       ( hclk          ),      // ahb clk
        .hresetn    ( hresetn       ),      // ahb resetn
        // AHB - Slave side
        .haddr_s    ( haddr_s   [4] ),      // ahb slave address
        .hrdata_s   ( hrdata_s  [4] ),      // ahb slave read data
        .hwdata_s   ( hwdata_s  [4] ),      // ahb slave write data
        .hwrite_s   ( hwrite_s  [4] ),      // ahb slave write signal
        .htrans_s   ( htrans_s  [4] ),      // ahb slave trans
        .hsize_s    ( hsize_s   [4] ),      // ahb slave size
        .hburst_s   ( hburst_s  [4] ),      // ahb slave burst
        .hresp_s    ( hresp_s   [4] ),      // ahb slave response
        .hready_s   ( hready_s  [4] ),      // ahb slave ready
        .hsel_s     ( hsel_s    [4] ),      // ahb slave select
        // APB clock and reset
        .pclk       ( pclk          ),      // apb clk
        .presetn    ( presetn       ),      // apb resetn
        // APB - Master side
        .paddr      ( paddr         ),      // apb master address
        .pwdata     ( pwdata        ),      // apb master write data
        .prdata     ( prdata        ),      // apb master read data
        .pwrite     ( pwrite        ),      // apb master write signal
        .penable    ( penable       ),      // apb master enable
        .pready     ( pready        ),      // apb master ready
        .psel       ( psel          )       // apb master select
    );

    apb_router
    #(
        .slv_c      ( apb_slv_c     ),
        .a_w        ( a_w           )
    )
    apb_router_0
    (
        // clock and reset
        .pclk       ( pclk          ),  // pclk
        .presetn    ( presetn       ),  // presetn
        // APB master side
        .paddr_am   ( paddr_am      ),  // apb master address mask
        .paddr      ( paddr         ),  // apb master address
        .prdata     ( prdata        ),  // apb master read data
        .pwdata     ( pwdata        ),  // apb master write data
        .psel       ( psel          ),  // apb master select
        .pwrite     ( pwrite        ),  // apb master write
        .penable    ( penable       ),  // apb master enable
        .pready     ( pready        ),  // apb master ready
        // APB slave side
        .paddr_s    ( paddr_s       ),  // apb slave address
        .prdata_s   ( prdata_s      ),  // apb slave read data
        .pwdata_s   ( pwdata_s      ),  // apb slave write data
        .psel_s     ( psel_s        ),  // apb slave select
        .pwrite_s   ( pwrite_s      ),  // apb slave write
        .penable_s  ( penable_s     ),  // apb slave enable
        .pready_s   ( pready_s      )   // apb slave ready
    );

    gpio_apb 
    #(
        .gpio_w     ( gpio_w        )
    )
    gpio_apb_0
    (
        // clock and reset
        .pclk       ( pclk          ),  // pclk
        .presetn    ( presetn       ),  // presetn
        // bus side
        .paddr      ( paddr_s   [0] ),  // apb slave address
        .prdata     ( prdata_s  [0] ),  // apb slave read data
        .pwdata     ( pwdata_s  [0] ),  // apb slave write data
        .psel       ( psel_s    [0] ),  // apb slave select signal
        .pwrite     ( pwrite_s  [0] ),  // apb slave write signal
        .penable    ( penable_s [0] ),  // apb slave enable signal
        .pready     ( pready_s  [0] ),  // apb slave ready signal
        .pslverr    (               ),
        // IRQ
        .irq        ( p_gpi_irq     ),  // interrupt request
        // GPIO side
        .gpi        ( p_gpi         ),  // GPIO input
        .gpo        ( p_gpo         ),  // GPIO output
        .gpd        ( p_gpd         )   // GPIO direction
    );

    uart_apb
    uart_apb_0
    (
        // clock and reset
        .pclk       ( pclk          ),  // pclk
        .presetn    ( presetn       ),  // presetn
        // bus side
        .paddr      ( paddr_s   [1] ),  // apb slave address
        .prdata     ( prdata_s  [1] ),  // apb slave read data
        .pwdata     ( pwdata_s  [1] ),  // apb slave write data
        .psel       ( psel_s    [1] ),  // apb slave select signal
        .penable    ( penable_s [1] ),  // apb slave enable signal
        .pwrite     ( pwrite_s  [1] ),  // apb slave write signal
        .pready     ( pready_s  [1] ),  // apb slave ready signal
        .pslverr    (               ),  // apb slave error signal
        // IRQ
        .irq        ( p_uart_irq    ),  // interrupt request
        // UART side
        .uart_tx    ( p_uart_tx     ),  // UART tx wire
        .uart_rx    ( p_uart_rx     )   // UART rx wire
    );

    tmr_apb
    #(
        .tmr_w      ( tmr_w         )
    )
    tmr_apb_0
    (
        // clock and reset
        .pclk       ( pclk          ),  // pclk
        .presetn    ( presetn       ),  // presetn
        // bus side
        .paddr      ( paddr_s   [2] ),  // apb slave address
        .prdata     ( prdata_s  [2] ),  // apb slave read data
        .pwdata     ( pwdata_s  [2] ),  // apb slave write data
        .psel       ( psel_s    [2] ),  // apb slave select signal
        .penable    ( penable_s [2] ),  // apb slave enable signal
        .pwrite     ( pwrite_s  [2] ),  // apb slave write signal
        .pready     ( pready_s  [2] ),  // apb slave ready signal
        .pslverr    (               ),  // apb slave error signal
        // IRQ
        .irq        ( p_tmr_irq     ),  // interrupt request
        // TMR side
        .tmr_in     ( p_tmr_in      ),  // TMR input
        .tmr_out    ( p_tmr_out     )   // TMR output
    );

    spi_apb
    #(
        .cs_w       ( cs_w          )
    )
    spi_apb_0
    (
        // clock and reset
        .pclk       ( pclk          ),  // pclk
        .presetn    ( presetn       ),  // presetn
        // bus side
        .paddr      ( paddr_s   [3] ),  // apb slave address
        .prdata     ( prdata_s  [3] ),  // apb slave read data
        .pwdata     ( pwdata_s  [3] ),  // apb slave write data
        .psel       ( psel_s    [3] ),  // apb slave select signal
        .penable    ( penable_s [3] ),  // apb slave enable signal
        .pwrite     ( pwrite_s  [3] ),  // apb slave write signal
        .pready     ( pready_s  [3] ),  // apb slave ready signal
        .pslverr    (               ),  // apb slave error signal
        // IRQ
        .irq        ( p_spi_irq     ),  // interrupt request
        // SPI side
        .spi_mosi   ( p_spi_mosi    ),  // SPI mosi wire
        .spi_miso   ( p_spi_miso    ),  // SPI miso wire
        .spi_sck    ( p_spi_sck     ),  // SPI sck wire
        .spi_cs     ( p_spi_cs      )   // SPI cs wire
    );

    task write_data(logic [31 : 0] wr_addr, logic [31 : 0] wr_data);
        logic [31 : 0] wr_data_h;
        logic [31 : 0] wr_addr_h;
        haddr = wr_addr;
        hwrite = '1;
        htrans = '1;
        @(posedge hclk);
        htrans = '0;
        wr_data_h = wr_data;
        wr_addr_h = wr_addr;
        fork
            begin
                hwdata = wr_data_h;
            end
        join_none
        wait(hready == '1);
        @(posedge hclk);
    endtask : write_data

    task read_data(logic [31 : 0] rd_addr);
        logic [31 : 0] rd_addr_h;
        haddr = rd_addr;
        hwrite = '0;
        htrans = '1;
        @(posedge hclk);
        htrans = '0;
        rd_addr_h = rd_addr;
        wait(hready == '1);
        @(posedge hclk);
        fork
            begin
                @(posedge hclk);
                data_rq[rd_addr_h] = hrdata;
                $display("rd_addr = 0x%h, rd_data = 0x%h", rd_addr_h, hrdata );
            end
        join_none
    endtask : read_data

    // AHB
    initial
    begin
        # start_del;
        hclk = '0;
        forever
            #(T/2) hclk <= !hclk;
    end

    initial
    begin
        # start_del;
        hresetn = '0;
        repeat(rst_delay) @(posedge hclk);
        hresetn = '1;
    end

    initial
    begin
        # start_del;
        @(posedge hresetn);
        haddr = '0;
        hwdata = '0;
        hwrite = '0;
        htrans = '0;
        hsize = '0;
        hburst = '0;
        repeat(20) 
        begin
            write_data( GPIO_GPO , $urandom_range(0,2**8-1) );
        end
        repeat(20) 
        begin
            write_data( 32'h0004_0000 | GPIO_GPO , $urandom_range(0,2**8-1) );
        end
        $stop;
    end

    // APB
    initial
    begin
        # start_del;
        pclk = '0;
        forever
            #(Tp/2) pclk <= !pclk;
    end

    initial
    begin
        # start_del;
        presetn = '0;
        repeat(rst_delay) @(posedge pclk);
        presetn = '1;
    end

endmodule : ahb_apb_test_system_tb
