/*
*  File            :   avalon_if.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.27
*  Language        :   SystemVerilog
*  Description     :   This is avalon interface
*  Copyright(c)    :   2019 Vlasov D.V.
*/

interface avalon_if
(
    input   logic   [0 : 0]     clk,
    input   logic   [0 : 0]     rstn
);

    // bus side
    logic   [31 : 0]    address;        // avalon slave address
    logic   [31 : 0]    readdata;       // avalon slave read data
    logic   [31 : 0]    writedata;      // avalon slave write data
    logic   [0  : 0]    write;          // avalon slave write signal
    logic   [0  : 0]    chipselect;     // avalon slave chip select signal

endinterface : avalon_if
