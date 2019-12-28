/*
*  File            :   uart_test_pkg.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is package for uart test
*  Copyright(c)    :   2019 Vlasov D.V.
*/

package uart_test_pkg;

    import dvv_vm_pkg::*;
    //`include "../../../dvv_vm/dvv_macro.svh"
    `include "D:/DM/work/my_periph/dvv_vm/dvv_macro.svh"
    `include "../../rtl/uart.svh"

    `include "sif_trans.sv"
    
    `include "apb_drv.sv"
    `include "apb_mon.sv"
    `include "apb_agt.sv"

    `include "sif_drv.sv"
    `include "sif_mon.sv"
    `include "sif_agt.sv"
    `include "sif_gen.sv"
    `include "sif_rgen.sv"
    `include "sif_dgen.sv"

    `include "uart_mon.sv"

    `include "uart_test.sv"
    `include "uart_rtest.sv"
    `include "uart_dtest.sv"

endpackage : uart_test_pkg
