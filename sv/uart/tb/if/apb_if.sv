/*
*  File            :   apb_if.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.27
*  Language        :   SystemVerilog
*  Description     :   This is apb interface
*  Copyright(c)    :   2019 Vlasov D.V.
*/

interface apb_if
(
    input   logic   [0 : 0]     pclk,
    input   logic   [0 : 0]     presetn
);

    // bus side
    logic   [31 : 0]    paddr;      // apb slave address
    logic   [31 : 0]    prdata;     // apb slave read data
    logic   [31 : 0]    pwdata;     // apb slave write data
    logic   [0  : 0]    psel;       // apb slave select signal
    logic   [0  : 0]    penable;    // apb slave enable signal
    logic   [0  : 0]    pwrite;     // apb slave write signal
    logic   [0  : 0]    pready;     // apb slave ready signal
    logic   [0  : 0]    pslverr;    // apb slave error signal

endinterface : apb_if
