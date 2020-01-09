/* 
*  File            :   gpio_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.06
*  Language        :   SystemVerilog
*  Description     :   This gpio testbench
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

module gpio_tb();

    timeprecision           1ns;
    timeunit                1ns;

    parameter               T = 10,
                            start_del = 200,
                            rst_delay = 7,
                            repeat_n = 2000;

    parameter               gpio_w = 8;

    // clock and reset
    logic   [0        : 0]  clk;    // clock
    logic   [0        : 0]  rstn;   // reset
    // bus side
    logic   [31       : 0]  addr;   // address
    logic   [0        : 0]  we;     // write enable
    logic   [31       : 0]  wd;     // write data
    logic   [31       : 0]  rd;     // read data
    // interrupt
    logic   [0        : 0]  irq;    // interrupt
    // GPIO side
    logic   [gpio_w-1 : 0]  gpi;    // GPIO input
    logic   [gpio_w-1 : 0]  gpo;    // GPIO output
    logic   [gpio_w-1 : 0]  gpd;    // GPIO direction

    logic   [gpio_w-1 : 0]  irq_v;

    gpio
    #(
        .gpio_w     ( gpio_w        )
    )
    dut
    (
        // clock and reset
        .clk        ( clk           ),  // clock
        .rstn       ( rstn          ),  // reset
        // bus side
        .addr       ( addr          ),  // address
        .we         ( we            ),  // write enable
        .wd         ( wd            ),  // write data
        .rd         ( rd            ),  // read data
        // interrupt
        .irq        ( irq           ),  // interrupt
        // GPIO side
        .gpi        ( gpi           ),  // GPIO input
        .gpo        ( gpo           ),  // GPIO output
        .gpd        ( gpd           )   // GPIO direction
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
            #(T/2) clk <= !clk;
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
        gpi = '0;
        addr = '0;
        we = '0; 
        wd = '0; 
        write_reg(5'h0C, 8'h03);
        write_reg(5'h10, 8'h02);
        repeat(repeat_n) 
        begin
            @(posedge clk);
            #0;
            if( irq )
            begin
                read_reg(5'h14, irq_v);
                $display("interrupt vector = 0x%h", irq_v);
                write_reg(5'h14, 8'h00);
            end
            gpi = $urandom_range(0,3);
        end
        $stop;
    end

endmodule : gpio_tb
