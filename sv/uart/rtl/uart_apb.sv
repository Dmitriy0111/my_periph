/*
*  File            :   uart_apb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.13
*  Language        :   SystemVerilog
*  Description     :   This is apb UART module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module uart_apb
(
    // clock and reset
    input   logic   [0  : 0]    pclk,       // apb clock
    input   logic   [0  : 0]    presetn,    // apb reset
    // bus side
    input   logic   [4  : 0]    paddr,      // apb slave address
    output  logic   [31 : 0]    prdata,     // apb slave read data
    input   logic   [31 : 0]    pwdata,     // apb slave write data
    input   logic   [0  : 0]    psel,       // apb slave select signal
    input   logic   [0  : 0]    penable,    // apb slave enable signal
    input   logic   [0  : 0]    pwrite,     // apb slave write signal
    output  logic   [0  : 0]    pready,     // apb slave ready signal
    output  logic   [0  : 0]    pslverr,    // apb slave error signal
    // IRQ
    output  logic   [0  : 0]    irq,        // interrupt request
    // UART side
    output  logic   [0  : 0]    uart_tx,    // UART tx wire
    input   logic   [0  : 0]    uart_rx     // UART rx wire
);

    logic   [4  : 0]    addr;
    logic   [0  : 0]    we;
    logic   [0  : 0]    re;
    logic   [31 : 0]    wd;
    logic   [31 : 0]    rd;

    assign pslverr = '0;

    assign addr = paddr;
    assign prdata = rd;
    assign we = psel &&   pwrite && penable;
    assign re = psel && ! pwrite && penable;
    assign wd = pwdata;
    assign pready = penable;

    uart
    uart_0
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
        // GPIO side
        .uart_tx    ( uart_tx   ),  // UART tx wire
        .uart_rx    ( uart_rx   )   // UART rx wire
    );

endmodule : uart_apb
