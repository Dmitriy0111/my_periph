/*
*  File            :   uart_avalon.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.13
*  Language        :   SystemVerilog
*  Description     :   This is avalon GPIO module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

module uart_avalon
(
    // clock and reset
    input   logic   [0  : 0]  clk,          // clock
    input   logic   [0  : 0]  rstn,         // reset
    // bus side
    input   logic   [2  : 0]  address,      // avalon slave address
    output  logic   [31 : 0]  readdata,     // avalon slave read data
    input   logic   [31 : 0]  writedata,    // avalon slave write data
    input   logic   [0  : 0]  write,        // avalon slave write signal
    input   logic   [0  : 0]  chipselect,   // avalon slave chip select signal
    // IRQ
    output  logic   [0  : 0]  irq,          // interrupt request
    // UART side
    output  logic   [0  : 0]  uart_tx,      // UART tx wire
    input   logic   [0  : 0]  uart_rx       // UART rx wire
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

    uart
    uart_0
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
        // GPIO side
        .uart_tx    ( uart_tx   ),  // UART tx wire
        .uart_rx    ( uart_rx   )   // UART rx wire
    );

endmodule : uart_avalon
