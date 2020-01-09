/* 
*  File            :   ahb_apb_test_system_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.23
*  Language        :   SystemVerilog
*  Description     :   This ahb, apb system testbench
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`include "../../gpio/rtl/gpio.svh"
`include "../../uart/rtl/uart.svh"
`include "../../tmr/rtl/tmr.svh"
`include "../../spi/rtl/spi.svh"

module ahb_apb_test_system_tb();

    timeprecision           1ns;
    timeunit                1ns;

    parameter               a_w = 16,
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
                            repeat_n = 2000,
                            stop_test_val = 1ms;

    parameter 
    logic   [ahb_slv_c-1 : 0][31       : 0]     haddr_am = 
    { 
        { 32'h0004_XXXX },
        { 32'h0003_XXXX },
        { 32'h0002_XXXX },
        { 32'h0001_XXXX },
        { 32'h0000_XXXX }
    };

    parameter 
    logic   [apb_slv_c-1 : 0][a_w-1    : 0]     paddr_am =  
    { 
        { 16'h0000_03XX },
        { 16'h0000_02XX },
        { 16'h0000_01XX },
        { 16'h0000_00XX }
    };

    parameter   bit     [31 : 0]    h_gpio_0_base = haddr_am[0];
    parameter   bit     [31 : 0]    h_uart_0_base = haddr_am[1];
    parameter   bit     [31 : 0]    h_tmr_0_base  = haddr_am[2];
    parameter   bit     [31 : 0]    h_spi_0_base  = haddr_am[3];
    parameter   bit     [31 : 0]    p_gpio_0_base = haddr_am[4] | paddr_am[0];
    parameter   bit     [31 : 0]    p_uart_0_base = haddr_am[4] | paddr_am[1];
    parameter   bit     [31 : 0]    p_tmr_0_base  = haddr_am[4] | paddr_am[2];
    parameter   bit     [31 : 0]    p_spi_0_base  = haddr_am[4] | paddr_am[3];

    // clock and reset
    logic                    [0        : 0]     hclk;       // ahb clock
    logic                    [0        : 0]     hresetn;    // ahb reset
    logic                    [0        : 0]     pclk;       // apb clock
    logic                    [0        : 0]     presetn;    // apb reset
    // AHB
    // Master side
    logic                    [31       : 0]     haddr;      // ahb master address
    logic                    [31       : 0]     hrdata;     // ahb master read data
    logic                    [31       : 0]     hwdata;     // ahb master write data
    logic                    [0        : 0]     hwrite;     // ahb master write signal
    logic                    [1        : 0]     htrans;     // ahb master transfer control signal
    logic                    [2        : 0]     hsize;      // ahb master size signal
    logic                    [2        : 0]     hburst;     // ahb master burst signal
    logic                    [1        : 0]     hresp;      // ahb master response signal
    logic                    [0        : 0]     hready;     // ahb master ready signal
    // AHB periph
    // TMR
    logic                    [0        : 0]     h_tmr_irq;  // interrupt request
    logic                    [0        : 0]     h_tmr_in;   // tmr input
    logic                    [0        : 0]     h_tmr_out;  // tmr output
    // SPI
    logic                    [0        : 0]     h_spi_irq;  // interrupt request
    logic                    [0        : 0]     h_spi_mosi; // SPI mosi wire
    logic                    [0        : 0]     h_spi_miso; // SPI miso wire
    logic                    [0        : 0]     h_spi_sck;  // SPI sck wire
    logic                    [cs_w-1   : 0]     h_spi_cs;   // SPI cs wire
    // UART
    logic                    [0        : 0]     h_uart_irq; // interrupt request
    logic                    [0        : 0]     h_uart_tx;  // UART tx wire
    logic                    [0        : 0]     h_uart_rx;  // UART rx wire
    // GPIO
    logic                    [0        : 0]     h_gpi_irq;  // interrupt request
    logic                    [gpio_w-1 : 0]     h_gpi;      // gpio input
    logic                    [gpio_w-1 : 0]     h_gpo;      // gpio output
    logic                    [gpio_w-1 : 0]     h_gpd;      // gpio direction
    // APB periph
    // TMR
    logic                    [0        : 0]     p_tmr_irq;  // interrupt request
    logic                    [0        : 0]     p_tmr_in;   // tmr input
    logic                    [0        : 0]     p_tmr_out;  // tmr output
    // SPI
    logic                    [0        : 0]     p_spi_irq;  // interrupt request
    logic                    [0        : 0]     p_spi_mosi; // SPI mosi wire
    logic                    [0        : 0]     p_spi_miso; // SPI miso wire
    logic                    [0        : 0]     p_spi_sck;  // SPI sck wire
    logic                    [cs_w-1   : 0]     p_spi_cs;   // SPI cs wire
    // UART
    logic                    [0        : 0]     p_uart_irq; // interrupt request
    logic                    [0        : 0]     p_uart_tx;  // UART tx wire
    logic                    [0        : 0]     p_uart_rx;  // UART rx wire
    // GPIO
    logic                    [0        : 0]     p_gpi_irq;  // interrupt request
    logic                    [gpio_w-1 : 0]     p_gpi;      // gpio input
    logic                    [gpio_w-1 : 0]     p_gpo;      // gpio output
    logic                    [gpio_w-1 : 0]     p_gpd;      // gpio direction

    gpio_struct     h_gpio_0 =  new_gpio( h_gpio_0_base );
    uart_struct     h_uart_0 =  new_uart( h_uart_0_base , 0 );
    tmr_struct      h_tmr_0  =  new_tmr ( h_tmr_0_base  );
    spi_struct      h_spi_0  =  new_spi ( h_spi_0_base  );
    
    gpio_struct     p_gpio_0 =  new_gpio( p_gpio_0_base );
    uart_struct     p_uart_0 =  new_uart( p_uart_0_base , 0 );
    tmr_struct      p_tmr_0  =  new_tmr ( p_tmr_0_base  );
    spi_struct      p_spi_0  =  new_spi ( p_spi_0_base  );

    string          msg = "Hello_world!";

    assign h_tmr_in = '0;
    assign h_spi_miso = '0;
    assign h_uart_rx = '0;
    assign h_gpi = '0;
    assign p_tmr_in = '0;
    assign p_spi_miso = '0;
    assign p_uart_rx = '0;
    assign p_gpi = '0;

    ahb_apb_test_system
    #(
        .ahb_slv_c      ( ahb_slv_c     ),
        .apb_slv_c      ( apb_slv_c     ),
        .a_w            ( a_w           ),
        .cs_w           ( cs_w          ),
        .gpio_w         ( gpio_w        ),
        .tmr_w          ( tmr_w         ),
        .cdc_use        ( cdc_use       )
    )
    dut
    (
        // clock and reset
        .hclk           ( hclk          ),  // ahb clock
        .hresetn        ( hresetn       ),  // ahb reset
        .pclk           ( pclk          ),  // apb clock
        .presetn        ( presetn       ),  // apb reset
        // AHB
        // Master side
        .haddr_am       ( haddr_am      ),  // ahb master address mask
        .paddr_am       ( paddr_am      ),  // apb master address mask
        .haddr          ( haddr         ),  // ahb master address
        .hrdata         ( hrdata        ),  // ahb master read data
        .hwdata         ( hwdata        ),  // ahb master write data
        .hwrite         ( hwrite        ),  // ahb master write signal
        .htrans         ( htrans        ),  // ahb master transfer control signal
        .hsize          ( hsize         ),  // ahb master size signal
        .hburst         ( hburst        ),  // ahb master burst signal
        .hresp          ( hresp         ),  // ahb master response signal
        .hready         ( hready        ),  // ahb master ready signal
        // AHB periph
        // TMR
        .h_tmr_irq      ( h_tmr_irq     ),  // interrupt request
        .h_tmr_in       ( h_tmr_in      ),  // tmr input
        .h_tmr_out      ( h_tmr_out     ),  // tmr output
        // SPI
        .h_spi_irq      ( h_spi_irq     ),  // interrupt request
        .h_spi_mosi     ( h_spi_mosi    ),  // SPI mosi wire
        .h_spi_miso     ( h_spi_miso    ),  // SPI miso wire
        .h_spi_sck      ( h_spi_sck     ),  // SPI sck wire
        .h_spi_cs       ( h_spi_cs      ),  // SPI cs wire
        // UART
        .h_uart_irq     ( h_uart_irq    ),  // interrupt request
        .h_uart_tx      ( h_uart_tx     ),  // UART tx wire
        .h_uart_rx      ( h_uart_rx     ),  // UART rx wire
        // GPIO
        .h_gpi_irq      ( h_gpi_irq     ),  // interrupt request
        .h_gpi          ( h_gpi         ),  // gpio input
        .h_gpo          ( h_gpo         ),  // gpio output
        .h_gpd          ( h_gpd         ),  // gpio direction
        // APB periph
        // TMR
        .p_tmr_irq      ( p_tmr_irq     ),  // interrupt request
        .p_tmr_in       ( p_tmr_in      ),  // tmr input
        .p_tmr_out      ( p_tmr_out     ),  // tmr output
        // SPI
        .p_spi_irq      ( p_spi_irq     ),  // interrupt request
        .p_spi_mosi     ( p_spi_mosi    ),  // SPI mosi wire
        .p_spi_miso     ( p_spi_miso    ),  // SPI miso wire
        .p_spi_sck      ( p_spi_sck     ),  // SPI sck wire
        .p_spi_cs       ( p_spi_cs      ),  // SPI cs wire
        // UART
        .p_uart_irq     ( p_uart_irq    ),  // interrupt request
        .p_uart_tx      ( p_uart_tx     ),  // UART tx wire
        .p_uart_rx      ( p_uart_rx     ),  // UART rx wire
        // GPIO
        .p_gpi_irq      ( p_gpi_irq     ),  // interrupt request
        .p_gpi          ( p_gpi         ),  // gpio input
        .p_gpo          ( p_gpo         ),  // gpio output
        .p_gpd          ( p_gpd         )   // gpio direction
    );

    // AHB write single transaction 
    task ahb_write_data_st(logic [31 : 0] wr_addr, logic [31 : 0] wr_data);
        logic [31 : 0] wr_data_h;
        haddr = wr_addr;
        hwrite = '1;
        htrans = '1;
        @(posedge hclk);
        hwrite = '0;
        htrans = '0;
        hwdata = wr_data;
        @(posedge hclk);
        wait(hready == '1);
        @(posedge hclk);
    endtask : ahb_write_data_st
    // AHB read single transaction 
    task ahb_read_data_st(logic [31 : 0] rd_addr, output logic [31 : 0] rd_data);
        haddr = rd_addr;
        hwrite = '0;
        htrans = '1;
        @(posedge hclk);
        htrans = '0;
        wait(hready == '1);
        @(posedge hclk);
        rd_data = hrdata;
    endtask : ahb_read_data_st

    // AHB
    initial
    fork
        begin : ahb_clk_gen
            # start_del;
            hclk = '0;
            forever
                #(T/2) hclk <= !hclk;
        end
        begin : ahb_rst_gen
            # start_del;
            hresetn = '0;
            repeat(rst_delay) @(posedge hclk);
            hresetn = '1;
        end
    join_none

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
            h_gpio_0.gpo_c.data = $urandom_range(0,2**8-1);
            $display("New h_gpo_0 val = %h", h_gpio_0.gpo_c.data);
            ahb_write_data_st( h_gpio_0.gpo_c.addr , h_gpio_0.gpo_c.data );
        end

        h_uart_0.dfr_c.data = 40;

        h_uart_0.cr_c.data.rx_fifo_lvl = '0;
        h_uart_0.cr_c.data.tx_fifo_lvl = '0;
        h_uart_0.cr_c.data.rec_en      = '0;
        h_uart_0.cr_c.data.tr_en       = '1;

        ahb_write_data_st( h_uart_0.cr_c.addr , h_uart_0.cr_c.data );
        ahb_write_data_st( h_uart_0.dfr_c.addr , h_uart_0.dfr_c.data );

        for( int i = 0 ; i < msg.len() ; i ++ ) 
        begin
            h_uart_0.tx_rx_c.data = msg[i];
            $info("New uart tx val = %c", h_uart_0.tx_rx_c.data);
            ahb_write_data_st( h_uart_0.tx_rx_c.addr , h_uart_0.tx_rx_c.data );
            for(;;)
            begin
                ahb_read_data_st( h_uart_0.cr_c.addr , h_uart_0.cr_c.data );
                if( h_uart_0.cr_c.data.tx_full == 0 )
                    break;
            end
        end

        repeat(20) 
        begin
            p_gpio_0.gpo_c.data = $urandom_range(0,2**8-1);
            $display("New p_gpo_0 val = %h", p_gpio_0.gpo_c.data);
            ahb_write_data_st( p_gpio_0.gpo_c.addr , p_gpio_0.gpo_c.data );
        end

        p_uart_0.dfr_c.data = 22;

        p_uart_0.cr_c.data.rx_fifo_lvl = '0;
        p_uart_0.cr_c.data.tx_fifo_lvl = '0;
        p_uart_0.cr_c.data.rec_en      = '0;
        p_uart_0.cr_c.data.tr_en       = '1;

        ahb_write_data_st( p_uart_0.cr_c.addr , p_uart_0.cr_c.data );
        ahb_write_data_st( p_uart_0.dfr_c.addr , p_uart_0.dfr_c.data );

        for( int i = 0 ; i < msg.len() ; i ++ ) 
        begin
            p_uart_0.tx_rx_c.data = msg[i];
            $info("New uart tx val = %c (%h)", p_uart_0.tx_rx_c.data,p_uart_0.tx_rx_c.data);
            ahb_write_data_st( p_uart_0.tx_rx_c.addr , p_uart_0.tx_rx_c.data );
            for(;;)
            begin
                ahb_read_data_st( p_uart_0.cr_c.addr , p_uart_0.cr_c.data );
                if( p_uart_0.cr_c.data.tx_full == 0 )
                    break;
            end
        end

        $stop;
    end

    // APB
    initial
    fork
        begin : apb_clk_gen
            # start_del;
            pclk = '0;
            forever
                #(Tp/2) pclk <= !pclk;
        end
        begin : apb_rst_gen
            # start_del;
            presetn = '0;
            repeat(rst_delay) @(posedge pclk);
            presetn = '1;
        end
    join_none
    //
    initial
    begin
        # start_del;
        # stop_test_val;
        $stop;
    end
    // uart_rec_ahb
    initial
    begin
        logic   [7 : 0] rec_data;
        # start_del;
        forever
        begin
            @(negedge h_uart_tx);
            repeat( h_uart_0.dfr_c.data ) @(posedge hclk);

            repeat(8)
            begin
                repeat( h_uart_0.dfr_c.data >> 1 ) @(posedge hclk);
                rec_data = { h_uart_tx , rec_data[7 : 1] }; 
                repeat( h_uart_0.dfr_c.data >> 1 ) @(posedge hclk);
            end

            repeat( h_uart_0.dfr_c.data ) @(posedge hclk);
            $display("h_uart_mon rec_data = %c (0x%h)", rec_data, rec_data);
        end
    end
    // uart_rec_apb
    initial
    begin
        logic   [7 : 0] rec_data;
        # start_del;
        forever
        begin
            @(negedge p_uart_tx);
            rec_data = '0;
            repeat( p_uart_0.dfr_c.data ) @(posedge pclk);

            repeat(8)
            begin
                repeat( p_uart_0.dfr_c.data / 2 ) @(posedge pclk);
                rec_data = { p_uart_tx , rec_data[7 : 1] }; 
                repeat( p_uart_0.dfr_c.data / 2 ) @(posedge pclk);
            end

            $display("p_uart_mon rec_data = %c (0x%h)", rec_data, rec_data);
        end
    end

endmodule : ahb_apb_test_system_tb
