/*
*  File            :   gpio_avalon.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.12
*  Language        :   SystemVerilog
*  Description     :   This is avalon GPIO module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module gpio_avalon
#(
    parameter                       gpio_w = 8
)(
    // clock and reset
    input   logic   [0        : 0]  clk,            // clock
    input   logic   [0        : 0]  rstn,           // reset
    // bus side
    input   logic   [2        : 0]  address,        // avalon slave address
    output  logic   [31       : 0]  readdata,       // avalon slave read data
    input   logic   [31       : 0]  writedata,      // avalon slave write data
    input   logic   [0        : 0]  write,          // avalon slave write signal
    input   logic   [0        : 0]  chipselect,     // avalon slave chip select signal
    // IRQ
    output  logic   [0        : 0]  irq,            // interrupt request
    // GPIO side
    input   logic   [gpio_w-1 : 0]  gpi,            // GPIO input
    output  logic   [gpio_w-1 : 0]  gpo,            // GPIO output
    output  logic   [gpio_w-1 : 0]  gpd             // GPIO direction
);

    logic   [4  : 0]    addr;
    logic   [0  : 0]    we;
    logic   [31 : 0]    wd;
    logic   [31 : 0]    rd;

    assign addr = { address , 2'b00 };
    assign we = chipselect && write;
    assign wd = writedata;

    reg_we  #( 32 ) rd_ff   ( clk , rstn , '1 , rd , readdata );

    gpio
    #(
        .gpio_w     ( gpio_w    )
    )
    gpio_0
    (
        // clock and reset
        .clk        ( clk       ),  // clock
        .rstn       ( rstn      ),  // reset
        // bus side
        .addr       ( addr      ),  // address
        .we         ( we        ),  // write enable
        .wd         ( wd        ),  // write data
        .rd         ( rd        ),  // read data
        // IRQ
        .irq        ( irq       ),  // interrupt request
        // GPIO side
        .gpi        ( gpi       ),  // GPIO input
        .gpo        ( gpo       ),  // GPIO output
        .gpd        ( gpd       )   // GPIO direction
    );

endmodule : gpio_avalon
