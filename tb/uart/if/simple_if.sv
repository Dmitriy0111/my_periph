/*
*  File            :   simple_if.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is simple interface
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

interface simple_if
(
    input   logic   [0 : 0]     clk,
    input   logic   [0 : 0]     rstn
);

    // simple interface
    logic   [4  : 0]    addr;       // address
    logic   [0  : 0]    re;         // read enable
    logic   [0  : 0]    we;         // write enable
    logic   [31 : 0]    wd;         // write data
    logic   [31 : 0]    rd;         // read data

endinterface : simple_if
