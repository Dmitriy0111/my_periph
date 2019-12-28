/*
*  File            :   irq_if.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is interrupt interface
*  Copyright(c)    :   2019 Vlasov D.V.
*/

interface irq_if
    (
        input   logic   [0 : 0]     clk,
        input   logic   [0 : 0]     rstn
    );

        // IRQ
        logic   [0  : 0]    irq;    // interrupt request
    
endinterface : irq_if
    