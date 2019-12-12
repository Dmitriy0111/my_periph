/*
*  File            :   gpio.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.06
*  Language        :   SystemVerilog
*  Description     :   This is GPIO constants
*  Copyright(c)    :   2019 Vlasov D.V.
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

`endif // SVH__GPIO
