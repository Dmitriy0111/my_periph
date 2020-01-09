/* 
*  File            :   tmr_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.17
*  Language        :   SystemVerilog
*  Description     :   This tmr testbench
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`include "../rtl/tmr.svh"

module tmr_tb();

    timeprecision       1ns;
    timeunit            1ns;

    parameter           T = 10,
                        start_del = 200,
                        rst_delay = 7,
                        repeat_n = 20000;

    parameter           tmr_w = 8;

    // clock and reset
    logic   [0  : 0]    clk;        // clock
    logic   [0  : 0]    rstn;       // reset
    // bus side
    logic   [4  : 0]    addr;       // address
    logic   [0  : 0]    we;         // write enable
    logic   [31 : 0]    wd;         // write data
    logic   [31 : 0]    rd;         // read data
    // IRQ
    logic   [0  : 0]    irq;        // interrupt request
    // TMR side
    logic   [0  : 0]    tmr_in;     // TMR input
    logic   [0  : 0]    tmr_out;    // TMR output

    tmr_cr_v            cr;
    int                 int_c = 0;

    tmr
    #(
        .tmr_w      ( tmr_w     )
    )
    dut
    (  
        // clock and reset
        .clk        ( clk       ),  // clock
        .rstn       ( rstn      ),  // reset
        // bus side
        .addr       ( addr      ),  // address
        .we         ( we        ),  // write enable
        .wd         ( wd        ),  // write data
        .rd         ( rd        ),  // read data
        // IRQ
        .irq        ( irq       ),  // interrupt request
        // TMR side
        .tmr_in     ( tmr_in    ),  // TMR input
        .tmr_out    ( tmr_out   )   // TMR output
    );

    task write_reg(integer w_addr, integer w_data);
        addr = w_addr;
        wd = w_data;
        we = '1;
        @(posedge clk);
        we = '0;
    endtask : write_reg

    task read_reg(integer r_addr, output integer r_data);
        addr = r_addr;
        @(posedge clk);
        r_data = rd;
    endtask : read_reg

    initial
    begin
        # start_del;
        clk = '0;
        forever
            #(T/2) clk = !clk;
    end

    initial
    begin
        # start_del;
        tmr_in = '0;
        forever
            #(T*20) tmr_in = !tmr_in;
    end

    initial
    begin
        # start_del;
        rstn = '0;
        repeat(rst_delay) @(posedge clk);
        rstn = '1;
    end

    initial
    begin
        # start_del;
        @(posedge rstn);
        addr = '0;
        we = '0; 
        wd = '0; 
        cr.tmr_ex = '0;
        cr.tmr_ie = '1;
        cr.tmr_r  = '0;
        write_reg(TMR_CR, cr);
        write_reg(TMR_RE, 8'h50);
        repeat(repeat_n) 
        begin
            @(posedge clk);
            #0;
            if( irq )
            begin
                $display("interrupt tmr %0d",int_c);
                write_reg(TMR_IR, 8'h00);
                int_c++;
            end
        end
        $stop;
    end

endmodule : tmr_tb
