/*
*  File            :   tmr.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.06
*  Language        :   SystemVerilog
*  Description     :   This is TMR constants
*  Copyright(c)    :   2019 Vlasov D.V.
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
} tmr_cr_v;

`endif // SVH__TMR
