/*
*  File            :   tmr_apb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.17
*  Language        :   SystemVerilog
*  Description     :   This is apb TMR module
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

module tmr_apb
#(
    parameter                   tmr_w = 8
)(
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
    // TMR side
    input   logic   [0  : 0]    tmr_in,     // TMR input
    output  logic   [0  : 0]    tmr_out     // TMR output
);

    logic   [4  : 0]    addr;
    logic   [0  : 0]    we;
    logic   [31 : 0]    wd;
    logic   [31 : 0]    rd;

    assign pslverr = '0;

    assign addr = paddr;
    assign prdata = rd;
    assign we = psel && pwrite && penable;
    assign wd = pwdata;
    assign pready = penable;

    tmr
    #(
        .tmr_w      ( tmr_w     )
    )
    tmr_0
    (
        // clock and reset
        .clk        ( pclk      ),  // clock
        .rstn       ( presetn   ),  // reset
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

endmodule : tmr_apb
