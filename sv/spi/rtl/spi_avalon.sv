/*
*  File            :   spi_avalon.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.17
*  Language        :   SystemVerilog
*  Description     :   This is avalon SPI module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module spi_avalon
#(
    parameter                       cs_w = 8
)(
    // clock and reset
    input   logic   [0      : 0]    clk,            // clock
    input   logic   [0      : 0]    rstn,           // reset
    // bus side
    input   logic   [2      : 0]    address,        // avalon slave address
    output  logic   [31     : 0]    readdata,       // avalon slave read data
    input   logic   [31     : 0]    writedata,      // avalon slave write data
    input   logic   [0      : 0]    write,          // avalon slave write signal
    input   logic   [0      : 0]    chipselect,     // avalon slave chip select signal
    // IRQ
    output  logic   [0      : 0]    irq,            // interrupt request
    // SPI side
    output  logic   [0      : 0]    spi_mosi,       // SPI mosi wire
    input   logic   [0      : 0]    spi_miso,       // SPI miso wire
    output  logic   [0      : 0]    spi_sck,        // SPI sck wire
    output  logic   [cs_w-1 : 0]    spi_cs          // SPI cs wire
);  

    logic   [4  : 0]    addr;
    logic   [0  : 0]    we;
    logic   [0  : 0]    re;
    logic   [31 : 0]    wd;
    logic   [31 : 0]    rd;

    logic   [0  : 0]    re_req;

    assign addr = { address , 2'b00 };
    assign we = chipselect && write;
    assign wd = writedata;

    assign re_req = chipselect && ! write;

    reg_we  #( 32 ) rd_ff   ( clk , rstn , '1 , rd     , readdata );
    reg_we  #( 1 )  re_ff   ( clk , rstn , '1 , re_req , re       );

    spi
    #(
        .cs_w       ( cs_w      )
    )
    spi_0
    (
        // clock and reset
        .clk        ( clk       ),  // clock
        .rstn       ( rstn      ),  // reset
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

endmodule : spi_avalon
