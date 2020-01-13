/*
*  File            :   sif_cov.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.10
*  Language        :   SystemVerilog
*  Description     :   This is simple interface coverage class 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef SIF_COV__SV
`define SIF_COV__SV

class sif_cov extends dvv_scr #(ctrl_trans);
    `OBJ_BEGIN( sif_cov )

    uart_struct     h_uart = new_uart( 0 , 0 );

    ctrl_trans      rec_item;

    covergroup sif_cg();

        addr_cp : coverpoint rec_item.addr {
            bins    cr_bin      = { h_uart.cr_c.addr    };
            bins    tx_rx_bin   = { h_uart.tx_rx_c.addr };
            bins    dfr_bin     = { h_uart.dfr_c.addr   };
            bins    irq_m_bin   = { h_uart.irq_m_c.addr };
            bins    irq_v_bin   = { h_uart.irq_v_c.addr };
        }

    endgroup : sif_cg

    extern function new(string name = "", dvv_bc parent = null);

    extern function write(ctrl_trans item);
    
endclass : sif_cov

function sif_cov::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
    item_ap = new(this);
    sif_cg = new();
endfunction : new

function sif_cov::write(ctrl_trans item);
    rec_item = item;
    sif_cg.sample();
endfunction : write

`endif // SIF_COV__SV
