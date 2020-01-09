/*
*  File            :   uart_if.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is uart interface
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

interface uart_if
(
    input   logic   [0 : 0]     clk,
    input   logic   [0 : 0]     rstn
);

    // uart side
    logic   [0  : 0]    uart_tx;    // UART tx wire
    logic   [0  : 0]    uart_rx;    // UART rx wire

endinterface : uart_if
