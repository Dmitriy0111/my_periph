/*
*  File            :   gpio.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.06
*  Language        :   SystemVerilog
*  Description     :   This is GPIO constants
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef SVH__GPIO
`define SVH__GPIO

typedef enum logic [4 : 0]
{
    GPIO_GPI    = 5'h00,
    GPIO_GPO    = 5'h04,
    GPIO_GPD    = 5'h08,
    GPIO_IRQ_M  = 5'h0C,
    GPIO_CAP    = 5'h10,
    GPIO_IRQ_V  = 5'h14
} gpio_e;

typedef struct packed
{
    logic   [31 : 0]    addr;
    logic   [31 : 0]    data;
} gpio_reg;

typedef struct packed
{
    gpio_reg    gpi_c;
    gpio_reg    gpo_c;
    gpio_reg    gpd_c;
    gpio_reg    irq_m_c;
    gpio_reg    cap_c;
    gpio_reg    irq_v_c;
} gpio_struct;

function gpio_struct new_gpio(bit [31 : 0] base);
    gpio_struct new_gpio_unit;

    new_gpio_unit.gpi_c.addr   = base | GPIO_GPI;
    new_gpio_unit.gpo_c.addr   = base | GPIO_GPO;
    new_gpio_unit.gpd_c.addr   = base | GPIO_GPD;
    new_gpio_unit.irq_m_c.addr = base | GPIO_IRQ_M;
    new_gpio_unit.cap_c.addr   = base | GPIO_CAP;
    new_gpio_unit.irq_v_c.addr = base | GPIO_IRQ_V;

    new_gpio_unit.gpi_c.data   = '0;
    new_gpio_unit.gpo_c.data   = '0;
    new_gpio_unit.gpd_c.data   = '0;
    new_gpio_unit.irq_m_c.data = '0;
    new_gpio_unit.cap_c.data   = '0;
    new_gpio_unit.irq_v_c.data = '0;
    
    return new_gpio_unit;
endfunction : new_gpio

`endif // SVH__GPIO
