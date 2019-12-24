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

typedef struct packed
{
    logic   [31 : 0]    addr;
    logic   [31 : 0]    data;
} uart_c_reg;

typedef struct packed
{
    logic   [31 : 0]    addr;
    uart_irq_v          data;
} uart_irq_v_reg;

typedef struct packed
{
    logic   [31 : 0]    addr;
    uart_cr_v           data;
} uart_cr_reg;

typedef struct packed
{
    uart_cr_reg     cr_c;
    uart_c_reg      tx_rx_c;
    uart_c_reg      dfr_c;
    uart_irq_v_reg  irq_m_c;
    uart_irq_v_reg  irq_v_c;
} uart_struct;

function uart_struct new_uart(bit [31 : 0] base);
    uart_struct new_uart_unit;

    new_uart_unit.cr_c.addr    = base | UART_CR;
    new_uart_unit.tx_rx_c.addr = base | UART_TX_RX;
    new_uart_unit.dfr_c.addr   = base | UART_DFR;
    new_uart_unit.irq_m_c.addr = base | UART_IRQ_M;
    new_uart_unit.irq_v_c.addr = base | UART_IRQ_V;

    new_uart_unit.cr_c.data    = '0;
    new_uart_unit.tx_rx_c.data = '0;
    new_uart_unit.dfr_c.data   = '0;
    new_uart_unit.irq_m_c.data = '0;
    new_uart_unit.irq_v_c.data = '0;
    
    return new_uart_unit;
endfunction : new_uart

`endif // SVH__UART
