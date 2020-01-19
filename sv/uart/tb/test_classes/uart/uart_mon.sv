/*
*  File            :   uart_mon.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.26
*  Language        :   SystemVerilog
*  Description     :   This is uart interface monitor 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef UART_MON__SV
`define UART_MON__SV

class uart_mon extends dvv_mon #(ctrl_trans);
    `OBJ_BEGIN( uart_mon )

    typedef uart_mon mon_t;

    logic   [15 : 0]                    dfr = 40;

    dvv_ap  #(logic [15 : 0], mon_t)    mon_ap;

    dvv_aep #(int)                      mon_aep;

    virtual uart_if                     vif;

    extern function new(string name = "", dvv_bc parent = null);

    extern task wait_clk();

    extern task build();
    extern task run();

    extern task mon_tx();
    extern task mon_rx();

    extern function void write(logic [15 : 0] item);
    
endclass : uart_mon

function uart_mon::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
    mon_ap = new(this);
    mon_aep = new();
endfunction : new

task uart_mon::wait_clk();
    @(posedge vif.clk);
endtask : wait_clk

task uart_mon::build();
    if( !dvv_res_db#(virtual uart_if)::get_res_db("uif_0",vif) )
        $fatal();
endtask : build

task uart_mon::run();
    fork
        mon_rx();
        mon_tx();
    join_none
endtask : run

task uart_mon::mon_tx();
    logic   [7 : 0]     rec_data;
    forever
    begin
        @(negedge vif.uart_tx);
        rec_data = '0;
        repeat(this.dfr) this.wait_clk();
        repeat(8)
        begin
            repeat(this.dfr>>1) this.wait_clk();
            rec_data = {vif.uart_tx , rec_data[7 : 1]};
            repeat(this.dfr>>1) this.wait_clk();
        end
        mon_aep.write(rec_data);
        $display("UART transmitted data on tx wire = %c (%h)", rec_data, rec_data);
    end
endtask : mon_tx

task uart_mon::mon_rx();
    logic   [7 : 0]     rec_data;
    forever
    begin
        @(negedge vif.uart_rx);
        rec_data = '0;
        repeat(this.dfr) this.wait_clk();
        repeat(8)
        begin
            repeat(this.dfr>>1) this.wait_clk();
            rec_data = {vif.uart_rx , rec_data[7 : 1]};
            repeat(this.dfr>>1) this.wait_clk();
        end
        $display("UART transmitted data on rx wire = %c (%h)", rec_data, rec_data);
    end
endtask : mon_rx

function void uart_mon::write(logic [15 : 0] item);
    this.dfr = item;
endfunction : write

`endif // UART_MON__SV
