/* 
*  File            :   spi.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.13
*  Language        :   SystemVerilog
*  Description     :   This is SPI constants
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
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

parameter   spi_irq_v_w = 2;

typedef struct packed 
{
    logic   [5 : 0]     res;
    logic   [0 : 0]     rx_fifo_full;
    logic   [0 : 0]     tx_fifo_emp;
} spi_irq_v;

typedef struct packed
{
    logic   [31 : 0]    addr;
    logic   [31 : 0]    data;
} spi_c_reg;

typedef struct packed
{
    logic   [31 : 0]    addr;
    spi_irq_v           data;
} spi_irq_v_reg;

typedef struct packed
{
    logic   [31 : 0]    addr;
    spi_sr_v            data;
} spi_sr_reg;

typedef struct packed
{
    logic   [31 : 0]    addr;
    spi_cr_v            data;
} spi_cr_reg;

typedef struct packed
{
    spi_cr_reg      cr_c;
    spi_c_reg       dr_c;
    spi_c_reg       dfr_c;
    spi_c_reg       irq_m_c;
    spi_irq_v_reg   irq_v_c;
    spi_c_reg       cs_v_c;
    spi_sr_reg      sr_c;
} spi_struct;

function spi_struct new_spi(bit [31 : 0] base);
    spi_struct new_spi_unit;

    new_spi_unit.cr_c.addr    = base | SPI_CR;
    new_spi_unit.dr_c.addr    = base | SPI_DR;
    new_spi_unit.dfr_c.addr   = base | SPI_DFR;
    new_spi_unit.irq_m_c.addr = base | SPI_IRQ_M;
    new_spi_unit.irq_v_c.addr = base | SPI_IRQ_V;
    new_spi_unit.cs_v_c.addr  = base | SPI_CS_V;
    new_spi_unit.sr_c.addr    = base | SPI_SR;

    new_spi_unit.cr_c.data    = '0;
    new_spi_unit.dr_c.data    = '0;
    new_spi_unit.dfr_c.data   = '0;
    new_spi_unit.irq_m_c.data = '0;
    new_spi_unit.irq_v_c.data = '0;
    new_spi_unit.cs_v_c.data  = '0;
    new_spi_unit.sr_c.data    = '0;
    
    return new_spi_unit;
endfunction : new_spi

`endif // SVH__SPI
