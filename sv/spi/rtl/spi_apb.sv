/*
*  File            :   spi_apb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.17
*  Language        :   SystemVerilog
*  Description     :   This is apb SPI module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module spi_apb
#(
    parameter                       cs_w = 8
)(
    // clock and reset
    input   logic   [0      : 0]    pclk,       // apb clock
    input   logic   [0      : 0]    presetn,    // apb reset
    // bus side
    input   logic   [4      : 0]    paddr,      // apb slave address
    output  logic   [31     : 0]    prdata,     // apb slave read data
    input   logic   [31     : 0]    pwdata,     // apb slave write data
    input   logic   [0      : 0]    psel,       // apb slave select signal
    input   logic   [0      : 0]    penable,    // apb slave enable signal
    input   logic   [0      : 0]    pwrite,     // apb slave write signal
    output  logic   [0      : 0]    pready,     // apb slave ready signal
    output  logic   [0      : 0]    pslverr,    // apb slave error signal
    // IRQ
    output  logic   [0      : 0]    irq,        // interrupt request
    // SPI side
    output  logic   [0      : 0]    spi_mosi,   // SPI mosi wire
    input   logic   [0      : 0]    spi_miso,   // SPI miso wire
    output  logic   [0      : 0]    spi_sck,    // SPI sck wire
    output  logic   [cs_w-1 : 0]    spi_cs      // SPI cs wire
);

    logic   [4  : 0]    addr;
    logic   [0  : 0]    we;
    logic   [0  : 0]    re;
    logic   [31 : 0]    wd;
    logic   [31 : 0]    rd;

    assign pslverr = '0;

    assign addr = paddr;
    assign we = psel &&   pwrite && penable;
    assign re = psel && ! pwrite && penable;
    assign wd = pwdata;
    assign pready = penable;

    spi
    #(
        .cs_w       ( cs_w      )
    )
    spi_0
    (
        // clock and reset
        .clk        ( pclk      ),  // clock
        .rstn       ( presetn   ),  // reset
        // bus side
        .addr       ( addr      ),  // address
        .re         ( re        ),  // read enable
        .we         ( we        ),  // write enable
        .wd         ( wd        ),  // write data
        .rd         ( rd        ),  // read data
        // IRQ
        .irq        ( irq       ),  // interrupt request
        // SPI side
        .spi_mosi   ( spi_mosi  ),  // SPI mosi wire
        .spi_miso   ( spi_miso  ),  // SPI miso wire
        .spi_sck    ( spi_sck   ),  // SPI sck wire
        .spi_cs     ( spi_cs    )   // SPI cs wire
    );

endmodule : spi_apb
