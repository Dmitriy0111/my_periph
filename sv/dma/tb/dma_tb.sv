/* 
*  File            :   dma_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.19
*  Language        :   SystemVerilog
*  Description     :   This dma testbench
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "../rtl/dma.svh"
import mem_pkg::*;

module dma_tb();

    timeprecision                   1ns;
    timeunit                        1ns;

    parameter                       T = 10,
                                    start_del = 200,
                                    rst_delay = 7,
                                    repeat_n = 10000;

    parameter                       m_w = 2,
                                    slv_c = 2,
                                    deb_log = 0;

    // clock and reset
    logic                [0  : 0]   clk;        // clock
    logic                [0  : 0]   rstn;       // reset
    // DMA REQ
    logic                [0  : 0]   dma_req;    // dma request
    // simple router address map
    logic   [slv_c-1 : 0][31 : 0]   addr_am;    // address map
    // simple router slave side
    logic   [slv_c-1 : 0][31 : 0]   addr_s;     // addr
    logic   [slv_c-1 : 0][0  : 0]   we_s;       // write enable data
    logic   [slv_c-1 : 0][31 : 0]   wd_s;       // write data
    logic   [slv_c-1 : 0][31 : 0]   rd_s;       // read data
    logic   [slv_c-1 : 0][1  : 0]   size_s;     // data size
    // arbiter bus control signals
    logic   [m_w-1   : 0]           bus_req;
    logic   [m_w-1   : 0]           bus_lock;
    logic   [m_w-1   : 0]           bus_grant;
    // arbiter bus master
    logic   [m_w-1   : 0][31 : 0]   addr_m;     // address
    logic   [m_w-1   : 0][31 : 0]   rd_m;       // read data
    logic   [m_w-1   : 0][31 : 0]   wd_m;       // write data
    logic   [m_w-1   : 0][0  : 0]   we_m;       // write enable
    logic   [m_w-1   : 0][1  : 0]   size_m;     // size
    // arbiter 2 simple router signals
    logic                [31 : 0]   addr_f;     // address
    logic                [31 : 0]   rd_f;       // read data
    logic                [31 : 0]   wd_f;       // write data
    logic                [0  : 0]   we_f;       // write enable
    logic                [1  : 0]   size_f;     // size
    // memory
    logic                [31 : 0]   addr_mem;
    logic                [3  : 0]   we_mem;
    logic                [31 : 0]   wd_mem;
    logic                [31 : 0]   rd_mem;

    dma_cr_v                        cr;
    logic   [31    : 0]             src_addr;
    logic   [31    : 0]             dst_addr;

    assign addr_mem = addr_s[0] >> 2;
    assign rd_s[0] = rd_mem;
    assign wd_mem = wd_s[0];
    assign we_mem[3] =  (
                            ( ( size_s[0] == 2'b10 ) || 
                            ( ( size_s[0] == 2'b01 ) && ( addr_s[0][0 +: 2] == 2'b10 ) ) || 
                            ( ( size_s[0] == 2'b00 ) && ( addr_s[0][0 +: 2] == 2'b11 ) ) ) && 
                            we_s[0] 
                        );
    
    assign we_mem[2] =  ( 
                            ( ( size_s[0] == 2'b10 ) || 
                            ( ( size_s[0] == 2'b01 ) && ( addr_s[0][0 +: 2] == 2'b10 ) ) || 
                            ( ( size_s[0] == 2'b00 ) && ( addr_s[0][0 +: 2] == 2'b10 ) ) ) && 
                            we_s[0]
                        );

    assign we_mem[1] =  ( 
                            ( ( size_s[0] == 2'b10 ) || 
                            ( ( size_s[0] == 2'b01 ) && ( addr_s[0][0 +: 2] == 2'b00 ) ) || 
                            ( ( size_s[0] == 2'b00 ) && ( addr_s[0][0 +: 2] == 2'b01 ) ) ) && 
                            we_s[0]
                        );

    assign we_mem[0] =  ( 
                            ( ( size_s[0] == 2'b10 ) || 
                            ( ( size_s[0] == 2'b01 ) && ( addr_s[0][0 +: 2] == 2'b00 ) ) || 
                            ( ( size_s[0] == 2'b00 ) && ( addr_s[0][0 +: 2] == 2'b00 ) ) ) && 
                            we_s[0]
                        );

    assign addr_am =   
                    { 
                        { 32'h0001_XXXX },
                        { 32'h0000_XXXX }
                    };

    dma
    dut
    (
        // clock and reset
        .clk        ( clk           ),      // clock
        .rstn       ( rstn          ),      // reset
        // DMA slave bus side
        .addr       ( addr_s    [1] ),      // address
        .we         ( we_s      [1] ),      // write enable
        .wd         ( wd_s      [1] ),      // write data
        .rd         ( rd_s      [1] ),      // read data
        .size       ( size_s    [1] ),      // size
        // REQ
        .dma_req    ( dma_req       ),      // dma request
        // DMA master bus control side
        .bus_req    ( bus_req   [1] ),      // bus request
        .bus_lock   ( bus_lock  [1] ),      // bus lock
        .bus_grant  ( bus_grant [1] ),      // bus grant
        // DMA master bus side
        .addr_m     ( addr_m    [1] ),      // address
        .we_m       ( we_m      [1] ),      // write enable
        .wd_m       ( wd_m      [1] ),      // write data
        .size_m     ( size_m    [1] ),      // tr size
        .rd_m       ( rd_m      [1] )       // read data
    );

    simple_arbiter
    #(
        .m_w        ( m_w           )
    )
    simple_arbiter_0
    (
        // clock and reset
        .clk        ( clk           ),  // clock
        .rstn       ( rstn          ),  // reset
        // bus control
        .bus_req    ( bus_req       ),  // bus request
        .bus_lock   ( bus_lock      ),  // bus lock
        .bus_grant  ( bus_grant     ),  // bus grant
        // bus master
        .addr_m     ( addr_m        ),  // address
        .rd_m       ( rd_m          ),  // read data
        .wd_m       ( wd_m          ),  // write data
        .we_m       ( we_m          ),  // write enable
        .size_m     ( size_m        ),  // size
        // bus slave
        .addr_f     ( addr_f        ),  // address
        .rd_f       ( rd_f          ),  // read data
        .wd_f       ( wd_f          ),  // write data
        .we_f       ( we_f          ),  // write enable
        .size_f     ( size_f        )   // size
    );

    simple_router
    #(
        .slv_c      ( slv_c         )
    )
    simple_router_0
    (
        // clock and reset
        .clk        ( clk           ),  // clock
        .rstn       ( rstn          ),  // reset
        //
        .addr_am    ( addr_am       ),  // address map
        // master side
        .addr       ( addr_f        ),  // addr
        .we         ( we_f          ),  // write enable data
        .wd         ( wd_f          ),  // write data
        .rd         ( rd_f          ),  // read data
        .size       ( size_f        ),  // data size
        // slave side
        .addr_s     ( addr_s        ),  // addr
        .we_s       ( we_s          ),  // write enable data
        .wd_s       ( wd_s          ),  // write data
        .rd_s       ( rd_s          ),  // read data
        .size_s     ( size_s        )   // data size
    );

    mem
    #(
        .depth      ( 65536         ),
        .d_w        ( 32            ),
        .b_c        ( 4             ),
        .mem_init   ( 1             ),
        .init_s     ( 8             ),
        .mem_v      ( mem_iv        )
    )
    test_mem
    (
        // clock
        .clk        ( clk           ),  // clock
        // bus side
        .addr       ( addr_mem      ),  // address
        .we         ( we_mem        ),  // write enable
        .wd         ( wd_mem        ),  // write data
        .rd         ( rd_mem        )   // read data
    );

    task write_reg(integer m_n, integer w_addr, integer w_size, integer w_data);
        addr_m[m_n] = w_addr;

        wd_m[m_n][24 +: 8] = w_data[24 +: 8];
        wd_m[m_n][16 +: 8] = w_data[16 +: 8];
        wd_m[m_n][8  +: 8] = w_data[8  +: 8];
        wd_m[m_n][0  +: 8] = w_data[0  +: 8];
        case( w_addr[0 +: 2] )
            2'b00   : wd_m[m_n][8  +: 8] = w_data[8  +: 8];
            2'b01   : wd_m[m_n][8  +: 8] = w_data[0  +: 8];
            default : ;
        endcase
        case( w_addr[0 +: 2] )
            2'b00   : wd_m[m_n][16 +: 8] = w_data[16 +: 8];
            2'b10   : wd_m[m_n][16 +: 8] = w_data[0  +: 8];
            default : ;
        endcase
        case( w_addr[0 +: 2] )
            2'b00   : wd_m[m_n][24 +: 8] = w_data[24 +: 8];
            2'b10   : wd_m[m_n][24 +: 8] = w_data[8  +: 8];
            2'b11   : wd_m[m_n][24 +: 8] = w_data[0  +: 8];
            default : ;
        endcase

        we_m[m_n] = '1;
        bus_req[m_n] = '1;
        bus_lock[m_n] = '1;
        size_m[m_n] = w_size;
        for(;;)
        begin
            @(posedge clk);
            if( bus_grant[m_n] )
                break;
        end
        bus_req[m_n] = '0;
        bus_lock[m_n] = '0;
        we_m[m_n] = '0;
    endtask : write_reg

    task read_reg(integer m_n, integer r_addr, integer r_size, output integer r_data);
        addr_m[m_n] = r_addr;
        bus_req[m_n] = '1;
        bus_lock[m_n] = '1;
        size_m[m_n] = r_size;
        for(;;)
        begin
            @(posedge clk);
            if( bus_grant[m_n] )
                break;
        end
        bus_req[m_n] = '0;
        bus_lock[m_n] = '0;

        r_data[24 +: 8] = rd_m[m_n][24 +: 8];
        r_data[16 +: 8] = rd_m[m_n][16 +: 8];
        r_data[8  +: 8] = rd_m[m_n][8  +: 8];
        r_data[0  +: 8] = rd_m[m_n][0  +: 8];
        case( r_addr[0 +: 2] )
            2'b00   : r_data[0  +: 8] = rd_m[m_n][0  +: 8];
            2'b01   : r_data[0  +: 8] = rd_m[m_n][8  +: 8];
            2'b10   : r_data[0  +: 8] = rd_m[m_n][16 +: 8];
            2'b11   : r_data[0  +: 8] = rd_m[m_n][24 +: 8];
            default : ;
        endcase
        case( r_addr[0 +: 2] )
            2'b00   : r_data[8  +: 8] = rd_m[m_n][8  +: 8];
            2'b01   : r_data[8  +: 8] = rd_m[m_n][8  +: 8];
            2'b10   : r_data[8  +: 8] = rd_m[m_n][24 +: 8];
            2'b11   : r_data[8  +: 8] = rd_m[m_n][24 +: 8];
            default : ;
        endcase

    endtask : read_reg

    function int rw_addr_gen(int base_addr, int base_size);
        int ret_v;
        ret_v = base_addr;
        ret_v -= ( base_size == 2'b10 ) ? 4 : ( base_size == 2'b01 ) ? 2 : 1;
        return ret_v;
    endfunction : rw_addr_gen

    task read_regs(int addr, int size, int cnt);
        logic [31 : 0] rw_data;
        repeat( cnt )
        begin
            read_reg( 0 , addr , size , rw_data );
            $display("addr = 0x%8h data = 0x%8h",addr,rw_data);
            addr += ( ( size == 2'b00 ) ? 1 : ( size == 2'b01 ) ? 2 : 4 );
        end
        $display();
    endtask : read_regs

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
        logic [31 : 0] rw_data;
        logic [31 : 0] rw_addr;
        # start_del;
        @(posedge rstn);
        dma_req = '0;

        bus_req[0] = '0;
        bus_lock[0] = '0;

        addr_m[0] = '0;
        wd_m[0] = '0;
        we_m[0] = '0;
        size_m[0] = '0;
        
        cr.cnt = 2;
        cr.src_size = 2'b10;
        cr.dst_size = 2'b10;
        cr.inc_src_a = '1;
        cr.inc_dst_a = '1;
        cr.line_en = '1;

        $display("Read area 0x%h:",32'h0000_0000);
        read_regs(32'h0000_0000, 2'b10, 8);

        repeat( repeat_n )
        begin
            src_addr = $urandom_range(32'h0000_0000,32'h0000_FFFF);
            dst_addr = $urandom_range(32'h0000_0000,32'h0000_FFFF);
            cr.cnt = $urandom_range(0,7);
            cr.src_size = $urandom_range(0,2);
            cr.dst_size = $urandom_range(0,2);
            src_addr = ( ( cr.src_size == 2'b10 ) ? ( src_addr & (~3) ) : ( ( cr.src_size == 2'b01 ) ? src_addr & (~1) : src_addr ) );
            dst_addr = ( ( cr.dst_size == 2'b10 ) ? ( dst_addr & (~3) ) : ( ( cr.dst_size == 2'b01 ) ? dst_addr & (~1) : dst_addr ) );

            write_reg( 0 , 32'h00010000 | DMA_CR      , 2'b10 , cr       );
            write_reg( 0 , 32'h00010000 | DMA_SRC_ADR , 2'b10 , src_addr );
            write_reg( 0 , 32'h00010000 | DMA_DST_ADR , 2'b10 , dst_addr );

            $display("test start at time %t ns", $time());
            $display("src_addr = 0x%8h dst_addr = 0x%8h dma_cnt = %0d src_size = %0d dst_size = %0d",src_addr,dst_addr,cr.cnt,cr.src_size,cr.dst_size);

            $display("Read area 0x%h:",src_addr);
            rw_addr = rw_addr_gen(src_addr,cr.src_size);
            read_regs(rw_addr, cr.src_size, cr.cnt + 3);

            rw_addr = src_addr;
            repeat( cr.cnt+1 )
            begin
                rw_data = $random();
                $display("write_addr = 0x%h write_data = 0x%h", rw_addr, rw_data);
                write_reg( 0 , rw_addr , cr.src_size , rw_data );
                rw_addr += ( ( cr.src_size == 2'b00 ) ? 1 : ( cr.src_size == 2'b01 ) ? 2 : 4 );
            end

            $display("Read area 0x%h:",src_addr);
            rw_addr = rw_addr_gen(src_addr,cr.src_size);
            read_regs(rw_addr, cr.src_size, cr.cnt + 3);

            $display("Read area 0x%h:",dst_addr);
            rw_addr = rw_addr_gen(dst_addr,cr.dst_size);
            read_regs(rw_addr, cr.dst_size, cr.cnt + 3);

            dma_req = '1;
            @(posedge clk);
            dma_req = '0;
            @(posedge clk);

            $display("Read area 0x%h:",dst_addr);
            rw_addr = rw_addr_gen(dst_addr,cr.dst_size);
            read_regs(rw_addr, cr.dst_size, cr.cnt + 3);
        end

        $stop;
    end

endmodule : dma_tb
