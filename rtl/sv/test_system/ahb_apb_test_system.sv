/* 
*  File            :   ahb_apb_test_system.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.23
*  Language        :   SystemVerilog
*  Description     :   This ahb, apb test system
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

module ahb_apb_test_system
#(
    parameter                                           ahb_slv_c = 5,
                                                        apb_slv_c = 4,
                                                        a_w = 12,
                                                        cs_w = 8,
                                                        gpio_w = 8,
                                                        tmr_w = 8,
                                                        cdc_use = '1
)(
    // clock and reset
    input   logic                    [0        : 0]     hclk,       // ahb clock
    input   logic                    [0        : 0]     hresetn,    // ahb reset
    input   logic                    [0        : 0]     pclk,       // apb clock
    input   logic                    [0        : 0]     presetn,    // apb reset
    // AHB
    // Master side
    input   logic   [ahb_slv_c-1 : 0][31       : 0]     haddr_am,   // ahb master address mask
    input   logic   [apb_slv_c-1 : 0][a_w-1    : 0]     paddr_am,   // apb master address mask
    input   logic                    [31       : 0]     haddr,      // ahb master address
    output  logic                    [31       : 0]     hrdata,     // ahb master read data
    input   logic                    [31       : 0]     hwdata,     // ahb master write data
    input   logic                    [0        : 0]     hwrite,     // ahb master write signal
    input   logic                    [1        : 0]     htrans,     // ahb master transfer control signal
    input   logic                    [2        : 0]     hsize,      // ahb master size signal
    input   logic                    [2        : 0]     hburst,     // ahb master burst signal
    output  logic                    [1        : 0]     hresp,      // ahb master response signal
    output  logic                    [0        : 0]     hready,     // ahb master ready signal
    // AHB periph
    // TMR
    output  logic                    [0        : 0]     h_tmr_irq,  // interrupt request
    input   logic                    [0        : 0]     h_tmr_in,   // tmr input
    output  logic                    [0        : 0]     h_tmr_out,  // tmr output
    // SPI
    output  logic                    [0        : 0]     h_spi_irq,  // interrupt request
    output  logic                    [0        : 0]     h_spi_mosi, // SPI mosi wire
    input   logic                    [0        : 0]     h_spi_miso, // SPI miso wire
    output  logic                    [0        : 0]     h_spi_sck,  // SPI sck wire
    output  logic                    [cs_w-1   : 0]     h_spi_cs,   // SPI cs wire
    // UART
    output  logic                    [0        : 0]     h_uart_irq, // interrupt request
    output  logic                    [0        : 0]     h_uart_tx,  // UART tx wire
    input   logic                    [0        : 0]     h_uart_rx,  // UART rx wire
    // GPIO
    output  logic                    [0        : 0]     h_gpi_irq,  // interrupt request
    input   logic                    [gpio_w-1 : 0]     h_gpi,      // gpio input
    output  logic                    [gpio_w-1 : 0]     h_gpo,      // gpio output
    output  logic                    [gpio_w-1 : 0]     h_gpd,      // gpio direction
    // APB periph
    // TMR
    output  logic                    [0        : 0]     p_tmr_irq,  // interrupt request
    input   logic                    [0        : 0]     p_tmr_in,   // tmr input
    output  logic                    [0        : 0]     p_tmr_out,  // tmr output
    // SPI
    output  logic                    [0        : 0]     p_spi_irq,  // interrupt request
    output  logic                    [0        : 0]     p_spi_mosi, // SPI mosi wire
    input   logic                    [0        : 0]     p_spi_miso, // SPI miso wire
    output  logic                    [0        : 0]     p_spi_sck,  // SPI sck wire
    output  logic                    [cs_w-1   : 0]     p_spi_cs,   // SPI cs wire
    // UART
    output  logic                    [0        : 0]     p_uart_irq, // interrupt request
    output  logic                    [0        : 0]     p_uart_tx,  // UART tx wire
    input   logic                    [0        : 0]     p_uart_rx,  // UART rx wire
    // GPIO
    output  logic                    [0        : 0]     p_gpi_irq,  // interrupt request
    input   logic                    [gpio_w-1 : 0]     p_gpi,      // gpio input
    output  logic                    [gpio_w-1 : 0]     p_gpo,      // gpio output
    output  logic                    [gpio_w-1 : 0]     p_gpd       // gpio direction
);

    // ahb router signals
    // Slaves side
    logic   [ahb_slv_c-1 : 0][31    : 0]    haddr_s;    // ahb slave address
    logic   [ahb_slv_c-1 : 0][31    : 0]    hrdata_s;   // ahb slave read data
    logic   [ahb_slv_c-1 : 0][31    : 0]    hwdata_s;   // ahb slave write data
    logic   [ahb_slv_c-1 : 0][0     : 0]    hwrite_s;   // ahb slave write signal
    logic   [ahb_slv_c-1 : 0][1     : 0]    htrans_s;   // ahb slave transfer control signal
    logic   [ahb_slv_c-1 : 0][2     : 0]    hsize_s;    // ahb slave size signal
    logic   [ahb_slv_c-1 : 0][2     : 0]    hburst_s;   // ahb slave burst signal
    logic   [ahb_slv_c-1 : 0][1     : 0]    hresp_s;    // ahb slave response signal
    logic   [ahb_slv_c-1 : 0][0     : 0]    hready_s;   // ahb slave ready signal
    logic   [ahb_slv_c-1 : 0][0     : 0]    hsel_s;     // ahb slave select signal
    // apb router signals
    // APB master side
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

endmodule : ahb_apb_test_system
