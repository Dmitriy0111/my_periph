/*
*  File            :   tmr_avalon.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.17
*  Language        :   SystemVerilog
*  Description     :   This is avalon TMR module
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

module tmr_avalon
#(
    parameter                   tmr_w = 8
)(
    // clock and reset
    input   logic   [0  : 0]    clk,            // clock
    input   logic   [0  : 0]    rstn,           // reset
    // bus side
    input   logic   [2  : 0]    address,        // avalon slave address
    output  logic   [31 : 0]    readdata,       // avalon slave read data
    input   logic   [31 : 0]    writedata,      // avalon slave write data
    input   logic   [0  : 0]    write,          // avalon slave write signal
    input   logic   [0  : 0]    chipselect,     // avalon slave chip select signal
    // IRQ
    output  logic   [0  : 0]    irq,            // interrupt request
    // TMR side
    input   logic   [0  : 0]    tmr_in,         // TMR input
    output  logic   [0  : 0]    tmr_out         // TMR output
);

    logic   [4  : 0]    addr;
    logic   [0  : 0]    we;
    logic   [31 : 0]    wd;
    logic   [31 : 0]    rd;

    assign addr = { address , 2'b00 };
    assign we = chipselect && write;
    assign wd = writedata;

    reg_we  #( 32 ) rd_ff   ( clk , rstn , '1 , rd , readdata );

    tmr
    #(
        .tmr_w      ( tmr_w     )
    )
    tmr_0
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
        // TMR side
        .tmr_in     ( tmr_in    ),  // TMR input
        .tmr_out    ( tmr_out   )   // TMR output
    );

endmodule : tmr_avalon
