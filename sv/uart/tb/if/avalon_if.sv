/*
*  File            :   avalon_if.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.27
*  Language        :   SystemVerilog
*  Description     :   This is avalon interface
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

interface avalon_if
(
    input   logic   [0 : 0]     clk,
    input   logic   [0 : 0]     rstn
);

    // bus side
    logic   [31 : 0]    address;        // avalon address
    logic   [31 : 0]    readdata;       // avalon read data
    logic   [31 : 0]    writedata;      // avalon write data
    logic   [0  : 0]    write;          // avalon write signal
    logic   [0  : 0]    chipselect;     // avalon chip select signal

endinterface : avalon_if
