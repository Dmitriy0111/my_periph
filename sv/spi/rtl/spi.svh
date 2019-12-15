/* 
*  File            :   spi.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.13
*  Language        :   SystemVerilog
*  Description     :   This is SPI constants
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef SVH__SPI
`define SVH__SPI

typedef enum logic [4 : 0]
{
    SPI_CR      = 5'h00,
    SPI_DR      = 5'h04,
    SPI_DFR     = 5'h08,
    SPI_IRQ_M   = 5'h0C,
    SPI_IRQ_V   = 5'h10,
    SPI_CS_V    = 5'h14,
    SPI_SR      = 5'h18
} spi_e;

typedef struct packed 
{
    logic   [1 : 0]     rx_fifo_lvl;
    logic   [1 : 0]     tx_fifo_lvl;
    logic   [0 : 0]     msb_lsb;
    logic   [0 : 0]     cpol;
    logic   [0 : 0]     cpha;
    logic   [0 : 0]     res;
} spi_cr_v;

typedef struct packed 
{
    logic   [4 : 0]     res;
    logic   [0 : 0]     rx_fifo_full;
    logic   [0 : 0]     tx_fifo_emp;
    logic   [0 : 0]     tx_fifo_full;
} spi_sr_v;

typedef struct packed 
{
    logic   [5 : 0]     res;
    logic   [0 : 0]     rx_fifo_full;
    logic   [0 : 0]     tx_fifo_emp;
} spi_irq_v;

`endif // SVH__SPI
