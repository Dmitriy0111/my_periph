/*
*  File            :   tmr.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.06
*  Language        :   SystemVerilog
*  Description     :   This is TMR constants
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef SVH__TMR
`define SVH__TMR

typedef enum logic [3 : 0]
{
    TMR_RE      = 4'h0,
    TMR_CR      = 4'h4,
    TMR_IR      = 4'h8
} tmr_e;

typedef struct packed 
{
    logic   [0 : 0]     tmr_ex;     // tmr external clock select
    logic   [0 : 0]     tmr_ie;     // tmr interrupt enable
    logic   [0 : 0]     tmr_r;      // tmr reload
    logic   [0 : 0]     tmr_en;
} tmr_cr_v;

typedef struct packed
{
    logic   [31 : 0]    addr;
    logic   [31 : 0]    data;
} tmr_c_reg;

typedef struct packed
{
    logic   [31 : 0]    addr;
    tmr_cr_v            data;
} tmr_cr_reg;

typedef struct packed
{
    tmr_c_reg       re_c;
    tmr_cr_reg      cr_c;
    tmr_c_reg       irq_v_c;
} tmr_struct;

function tmr_struct new_tmr(bit [31 : 0] base);
    tmr_struct new_tmr_unit;

    new_tmr_unit.re_c.addr    = base | TMR_RE;
    new_tmr_unit.cr_c.addr    = base | TMR_CR;
    new_tmr_unit.irq_v_c.addr = base | TMR_IR;

    new_tmr_unit.re_c.data    = '0;
    new_tmr_unit.cr_c.data    = '0;
    new_tmr_unit.irq_v_c.data = '0;
    
    return new_tmr_unit;
endfunction : new_tmr

`endif // SVH__TMR
