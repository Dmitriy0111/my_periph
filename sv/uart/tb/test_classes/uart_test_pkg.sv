/*
*  File            :   uart_test_pkg.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is package for uart test
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

package uart_test_pkg;

    import dvv_vm_pkg::*;
    `include "../../../../dvv_vm/dvv_macro.svh"

    `include "../../rtl/uart.svh"

    `include "ctrl_trans.sv"
    
    `include "sif/sif_mth.sv"
    `include "sif/sif_drv.sv"
    `include "sif/sif_mon.sv"
    `include "sif/sif_cov.sv"
    `include "sif/sif_agt.sv"

    `include "apb/apb_mth.sv"
    `include "apb/apb_drv.sv"
    `include "apb/apb_mon.sv"
    `include "apb/apb_agt.sv"

    `include "ahb/ahb_mth.sv"
    `include "ahb/ahb_drv.sv"
    `include "ahb/ahb_mon.sv"
    `include "ahb/ahb_agt.sv"

    `include "avalon/avalon_mth.sv"
    `include "avalon/avalon_drv.sv"
    `include "avalon/avalon_mon.sv"
    `include "avalon/avalon_agt.sv"

    `include "tr_gen.sv"
    `include "tr_rgen.sv"
    `include "tr_dgen.sv"
    
    `include "uart_mon.sv"

    `include "sif/sif_env.sv"
    `include "apb/apb_env.sv"
    `include "ahb/ahb_env.sv"
    `include "avalon/avalon_env.sv"

    `include "tests/uart_test.sv"
    `include "tests/uart_rtest.sv"
    `include "tests/uart_dtest.sv"

endpackage : uart_test_pkg
