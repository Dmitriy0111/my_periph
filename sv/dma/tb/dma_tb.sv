/* 
*  File            :   dma_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.19
*  Language        :   SystemVerilog
*  Description     :   This dma testbench
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "../rtl/dma.svh"

module dma_tb();

    timeprecision           1ns;
    timeunit                1ns;

    parameter               T = 10,
                            start_del = 200,
                            rst_delay = 7,
                            repeat_n = 2000;

    parameter               m_w = 2;

    // clock and reset
    logic   [0     : 0]     clk;        // clock
    logic   [0     : 0]     rstn;       // reset
    // bus side
    logic   [3     : 0]     addr;       // address
    logic   [0     : 0]     we;         // write enable
    logic   [31    : 0]     wd;         // write data
    logic   [31    : 0]     rd;         // read data
    // REQ
    logic   [0     : 0]     dma_req;    // dma request
    // DMA master side side
    logic   [31    : 0]     addr_m;     // address
    logic   [0     : 0]     we_m;       // write enable
    logic   [31    : 0]     wd_m;       // write data
    logic   [3     : 0]     byte_en;    // byte enable
    logic   [31    : 0]     rd_m;       // read data

    logic   [m_w-1 : 0]     bus_req;
    logic   [m_w-1 : 0]     bus_lock;
    logic   [m_w-1 : 0]     bus_grant;
    logic   [31    : 0]     addr_f;
    logic   [31    : 0]     wd_f;
    logic   [0     : 0]     we_f;

    dma_cr_v                cr;
    logic   [31    : 0]     src_addr;
    logic   [31    : 0]     dst_addr;

    dma
    dut
    (
        // clock and reset
        .clk        ( clk           ),      // clock
        .rstn       ( rstn          ),      // reset
        // bus side
        .addr       ( addr          ),      // address
        .we         ( we            ),      // write enable
        .wd         ( wd            ),      // write data
        .rd         ( rd            ),      // read data
        // REQ
        .dma_req    ( dma_req       ),      // dma request
        // DMA master side side
        .bus_req    ( bus_req[1]    ),      // bus request
        .bus_lock   ( bus_lock[1]   ),      // bus lock
        .bus_grant  ( bus_grant[1]  ),      // bus grant
        .addr_m     ( addr_m[1]     ),      // address
        .we_m       ( we_m[1]       ),      // write enable
        .wd_m       ( wd_m[1]       ),      // write data
        .byte_en    ( byte_en       ),      // byte enable
        .rd_m       ( rd_m          )       // read data
    );

    simple_arbiter
    #(
        .m_w        ( m_w       )
    )
    simple_arbiter_0
    (
        // clock and reset
        .clk        ( clk       ),  // clock
        .rstn       ( rstn      ),  // reset
        // bus side
        .bus_req    ( bus_req   ),  // bus request
        .bus_lock   ( bus_lock  ),  // bus lock
        .bus_grant  ( bus_grant ),  // bus grant
        .addr_m     ( addr_m    ),  // write data
        .wd_m       ( wd_m      ),  // write data
        .we_m       ( we_m      ),  // write data
        .addr_f     ( addr_f    ),  // write data
        .wd_f       ( wd_f      ),  // write data
        .we_f       ( we_f      )   // write data
    );

    task write_reg(integer w_addr, integer w_data);
        addr = w_addr;
        wd = w_data;
        we = '1;
        bus_req[0] = '1;
        bus_lock[0] = '1;
        for(;;)
        begin
            @(posedge clk);
            if( bus_grant[0] )
                break;
        end
        bus_req[0] = '0;
        bus_lock[0] = '0;
        we = '0;
    endtask : write_reg

    task read_reg(integer r_addr, output integer r_data);
        addr = r_addr;
        bus_req[0] = '1;
        bus_lock[0] = '1;
        for(;;)
        begin
            @(posedge clk);
            if( bus_grant[0] )
                break;
        end
        bus_req[0] = '0;
        bus_lock[0] = '0;
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
        dma_req = '0;
        rd_m = '0;
        cr.cnt = 2;
        cr.src_size = 2'b10;
        cr.dst_size = 2'b10;
        cr.inc_src_a = '1;
        cr.inc_dst_a = '0;
        cr.line_en = '1;

        src_addr = 32'h00000010;
        dst_addr = 32'h00010110;

        write_reg( DMA_CR      , cr       );
        write_reg( DMA_SRC_ADR , src_addr );
        write_reg( DMA_DST_ADR , dst_addr );

        repeat(repeat_n) 
        begin
            @(posedge clk);
        end
        $stop;
    end

endmodule : dma_tb
