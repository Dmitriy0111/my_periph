/*
*  File            :   uart.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.12
*  Language        :   SystemVerilog
*  Description     :   This is UART constants
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef SVH__UART
`define SVH__UART

typedef enum logic [5 : 0]
{
    UART_CR     = 5'h00,
    UART_TX_RX  = 5'h04,
    UART_DR     = 5'h08,
    UART_IRQ_M  = 5'h0C,
    UART_IRQ_V  = 5'h10
} uart_e;

typedef struct packed 
{
    logic   [3 : 0]     un;     // unused
    logic   [0 : 0]     rff;    // receiver fifo full
    logic   [0 : 0]     tfe;    // transmitter fifo empty
    logic   [0 : 0]     rc;     // receive complete
    logic   [0 : 0]     tc;     // transmit complete
} irq_v;

`endif // SVH__UART
