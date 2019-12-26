/*
*  File            :   uart_mon.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is uart interface monitor 
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef UART_MON__SV
`define UART_MON__SV

class uart_mon extends dvv_mon #(sif_trans);

    `OBJ_BEGIN( uart_mon )

    virtual uart_if     vif;

    extern function new(string name = "", dvv_bc parent = null);

    extern task     wait_clk();

    extern task     build();
    extern task     run();
    
endclass : uart_mon

function uart_mon::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task uart_mon::wait_clk();
    @(posedge vif.clk);
endtask : wait_clk

task uart_mon::build();
    if( !dvv_res_db#(virtual uart_if)::get_res_db("uif_0",vif) )
        $fatal();
    $display("%s build complete", this.name);
endtask : build

task uart_mon::run();
    logic   [7 : 0]     rec_data;
    forever
    begin
        @(negedge vif.uart_tx);
        rec_data = '0;
        repeat(40) this.wait_clk();
        repeat(8)
        begin
            repeat(40>>1) this.wait_clk();
            rec_data = {vif.uart_tx , rec_data[7 : 1]};
            repeat(40>>1) this.wait_clk();
        end
        $display("UART receive data = %c (%h)", rec_data, rec_data);
    end
endtask : run

`endif // UART_MON__SV
