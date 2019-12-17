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

typedef enum logic [4 : 0]
{
    UART_CR     = 5'h00,
    UART_TX_RX  = 5'h04,
    UART_DFR    = 5'h08,
    UART_IRQ_M  = 5'h0C,
    UART_IRQ_V  = 5'h10
} uart_e;

parameter   uart_irq_v_w = 4;

typedef struct packed 
{
    logic   [3 : 0]     un;     // unused
    logic   [0 : 0]     rff;    // receiver fifo full
    logic   [0 : 0]     tfe;    // transmitter fifo empty
    logic   [0 : 0]     rc;     // receive complete
    logic   [0 : 0]     tc;     // transmit complete
} uart_irq_v;

typedef struct packed 
{
    logic   [1 : 0]     rx_fifo_lvl;
    logic   [1 : 0]     tx_fifo_lvl;
    logic   [0 : 0]     rx_full;
    logic   [0 : 0]     tx_full;
    logic   [0 : 0]     rec_en;
    logic   [0 : 0]     tr_en;
} uart_cr_v;

`endif // SVH__UART
