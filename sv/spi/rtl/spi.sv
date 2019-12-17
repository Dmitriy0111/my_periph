/* 
*  File            :   spi.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.13
*  Language        :   SystemVerilog
*  Description     :   This is SPI module with simple interface
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "spi.svh"

module spi
#(
    parameter                       cs_w = 8
)(
    // reset and clock
    input   logic   [0      : 0]    clk,        // clk
    input   logic   [0      : 0]    rstn,       // reset
    // simple interface
    input   logic   [4      : 0]    addr,       // address
    input   logic   [0      : 0]    re,         // read enable
    input   logic   [0      : 0]    we,         // write enable
    input   logic   [31     : 0]    wd,         // write data
    output  logic   [31     : 0]    rd,         // read data
    // IRQ
    output  logic   [0      : 0]    irq,        // interrupt request
    // SPI side
    output  logic   [0      : 0]    spi_mosi,   // SPI mosi wire
    input   logic   [0      : 0]    spi_miso,   // SPI miso wire
    output  logic   [0      : 0]    spi_sck,    // SPI sck wire
    output  logic   [cs_w-1 : 0]    spi_cs      // SPI cs wire
);

    logic   [7      : 0]    dfr;            // "dividing" frequency register
    logic   [7      : 0]    rx_data;        
    logic   [7      : 0]    tx_data;        
    logic   [7      : 0]    rx_data_fifo;   
    logic   [7      : 0]    tx_data_fifo;   
    logic   [cs_w-1 : 0]    cs_v;           // chip select vector

    logic   [0      : 0]    tx_req;         // transmit request
    logic   [0      : 0]    tx_req_ack;     // transmit request acknowledge
    
    logic   [0      : 0]    cr_we;          // control register write enable
    logic   [0      : 0]    cs_v_we;        // control register write enable
    logic   [0      : 0]    tx_data_we;     // transmit data write enable
    logic   [0      : 0]    rx_data_re;     // receive data read enable
    logic   [0      : 0]    dfr_we;         // "dividing" frequency register write enable
    logic   [0      : 0]    irq_m_we;       // interrupt mask write enable
    logic   [0      : 0]    irq_v_we;       // interrupt vector write enable
    logic   [7      : 0]    irq_v_we_f;     // interrupt vector write enable final

    spi_cr_v                cr_in;
    spi_cr_v                cr_out;

    spi_sr_v                sr_out;
    spi_irq_v               irq_we;
    spi_irq_v               irq_m;
    spi_irq_v               irq_in;
    spi_irq_v               irq_out;

    genvar                  irq_i;

    assign cr_we      = we_find( we , addr , SPI_CR    );
    assign dfr_we     = we_find( we , addr , SPI_DFR   );
    assign irq_m_we   = we_find( we , addr , SPI_IRQ_M );
    assign irq_v_we   = we_find( we , addr , SPI_IRQ_V );
    assign tx_data_we = we_find( we , addr , SPI_DR    );
    assign rx_data_re = we_find( re , addr , SPI_DR    );
    assign cs_v_we    = we_find( we , addr , SPI_CS_V  );

    assign cr_in = wd[7 : 0];

    assign tx_data = wd[7 : 0];

    assign sr_out.res = '0;

    assign tx_req = ! sr_out.tx_fifo_emp;

    assign irq_we.res = '0;
    assign irq_we.rx_fifo_full = ( sr_out.rx_fifo_full && irq_m.rx_fifo_full );
    assign irq_we.tx_fifo_emp  = ( sr_out.tx_fifo_emp  && irq_m.tx_fifo_emp  );

    assign irq_v_we_f = irq_we | { 8 { irq_v_we } };

    generate
        for( irq_i = 0 ; irq_i < 8 ; irq_i++ )
        begin : gen_irq_in
            assign irq_in[irq_i] = irq_we[irq_i] ? '1 : wd[irq_i];
        end
    endgenerate

    assign irq = | irq_out;

    // mux for routing one register value
    always_comb
    begin
        rd = { '0 , cr_out };
        case( addr )
            SPI_CR     : rd = { '0 , cr_out       };
            SPI_DR     : rd = { '0 , rx_data_fifo };
            SPI_DFR    : rd = { '0 , dfr          };
            SPI_IRQ_M  : rd = { '0 , irq_m        };
            SPI_CS_V   : rd = { '0 , cs_v         };
            SPI_SR     : rd = { '0 , sr_out       };
            SPI_IRQ_V  : rd = { '0 , irq_out      };
        endcase
    end

    // creating control and data registers
    reg_we  #(    8 )   dfr_ff      ( clk , rstn , dfr_we        , wd[7      : 0]      , dfr                  );
    reg_we  #(    8 )   irq_m_ff    ( clk , rstn , irq_m_we      , wd[7      : 0]      , irq_m                );
    reg_we  #(    8 )   cr_ff       ( clk , rstn , cr_we         , cr_in               , cr_out               );
    reg_we  #( cs_w )   cs_v_ff     ( clk , rstn , cs_v_we       , wd[cs_w-1 : 0]      , cs_v                 );

    generate
        for( irq_i = 0 ; irq_i < spi_irq_v_w ; irq_i++ )
        begin : gen_irq_ff
            reg_we  #( 1 )  irq_ff  ( clk , rstn , irq_v_we_f[irq_i] , irq_in[irq_i] , irq_out[irq_i] );
        end
        for( irq_i = spi_irq_v_w ; irq_i < 8 ; irq_i++ )
        begin : gen_irq_oth_ff
            assign irq_out[irq_i] = '0;
        end
    endgenerate
    
    // creating one tx_fifo
    fifo
    #(
        .depth      ( 8                     ),
        .data_w     ( 8                     )
    )
    tx_fifo
    (
        // clock and reset
        .clk        ( clk                   ),  // clock
        .rstn       ( rstn                  ),  // reset
        // fifo write
        .fifo_lvl   ( cr_out.tx_fifo_lvl    ),  // fifo full level trigger
        .we         ( tx_data_we            ),  // write enable
        .wd         ( tx_data               ),  // write data
        .fifo_full  ( sr_out.tx_fifo_full   ),  // fifo full
        // fifo read
        .re         ( tx_req_ack            ),  // read enable
        .rd         ( tx_data_fifo          ),  // read data
        .fifo_emp   ( sr_out.tx_fifo_emp    )   // fifo empty
    );
    // creating one rx_fifo
    fifo
    #(
        .depth      ( 8                     ),
        .data_w     ( 8                     )
    )
    rx_fifo
    (
        // clock and reset
        .clk        ( clk                   ),  // clock
        .rstn       ( rstn                  ),  // reset
        // fifo write
        .fifo_lvl   ( cr_out.rx_fifo_lvl    ),  // fifo full level trigger
        .we         ( tx_req_ack            ),  // write enable
        .wd         ( rx_data               ),  // write data
        .fifo_full  ( sr_out.rx_fifo_full   ),  // fifo full
        // fifo read
        .re         ( rx_data_re            ),  // read enable
        .rd         ( rx_data_fifo          ),  // read data
        .fifo_emp   (                       )   // fifo empty
    );
    // creating one spi_tx_rx_0 unit
    spi_tx_rx
    #(
        .cs_w       ( cs_w                  )
    )
    spi_tx_rx_0
    (
        // reset and clock
        .clk        ( clk                   ),  // clk
        .rstn       ( rstn                  ),  // reset
        // control and data
        .cs_v       ( cs_v                  ),  // cs values
        .dfv        ( dfr                   ),  // dividing frequency value
        .tx_data    ( tx_data_fifo          ),  // data for transmitting
        .rx_data    ( rx_data               ),  // received data
        .cpol       ( cr_out.cpol           ),  // cpol value
        .cpha       ( cr_out.cpha           ),  // cpha value
        .msb_lsb    ( cr_out.msb_lsb        ),  // msb/lsb first
        .tx_req     ( tx_req                ),  // transmit request
        .tx_req_ack ( tx_req_ack            ),  // transmit request acknowledge
        // SPI side
        .spi_mosi   ( spi_mosi              ),  // SPI mosi wire
        .spi_miso   ( spi_miso              ),  // SPI miso wire
        .spi_sck    ( spi_sck               ),  // SPI sck wire
        .spi_cs     ( spi_cs                )   // SPI cs wire
    );

    function automatic logic [0 : 0] we_find(logic [0 : 0] we_in, logic [31 : 0] addr_in, logic [31 : 0] addr_v);
        return we_in && ( addr_in == addr_v );
    endfunction : we_find
    
endmodule : spi
