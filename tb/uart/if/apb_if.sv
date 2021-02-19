/*
*  File            :   apb_if.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.27
*  Language        :   SystemVerilog
*  Description     :   This is apb interface
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

interface apb_if
(
    input   logic   [0 : 0]     pclk,
    input   logic   [0 : 0]     presetn
);

    // bus side
    logic   [31 : 0]    paddr;      // apb address
    logic   [31 : 0]    prdata;     // apb read data
    logic   [31 : 0]    pwdata;     // apb write data
    logic   [0  : 0]    psel;       // apb select signal
    logic   [0  : 0]    penable;    // apb enable signal
    logic   [0  : 0]    pwrite;     // apb write signal
    logic   [0  : 0]    pready;     // apb ready signal
    logic   [0  : 0]    pslverr;    // apb error signal

endinterface : apb_if
