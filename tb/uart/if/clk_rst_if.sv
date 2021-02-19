/*
*  File            :   clk_rst_if.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is simple interface
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

interface clk_rst_if
(
    input   logic   [0 : 0]     clk,
    input   logic   [0 : 0]     rstn
);

endinterface : clk_rst_if
