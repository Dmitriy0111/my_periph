/*
*  File            :   dma.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.19
*  Language        :   SystemVerilog
*  Description     :   This is DMA module
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`include "dma.svh"

module dma
(
    // clock and reset
    input   logic   [0  : 0]    clk,        // clock
    input   logic   [0  : 0]    rstn,       // reset
    // DMA slave bus side
    input   logic   [3  : 0]    addr,       // address
    input   logic   [0  : 0]    we,         // write enable
    input   logic   [31 : 0]    wd,         // write data
    output  logic   [31 : 0]    rd,         // read data
    input   logic   [1  : 0]    size,       // size
    // REQ
    input   logic   [0  : 0]    dma_req,    // dma request
    // DMA master bus control side
    output  logic   [0  : 0]    bus_req,    // bus request
    output  logic   [0  : 0]    bus_lock,   // bus lock
    input   logic   [0  : 0]    bus_grant,  // bus grant
    // DMA master bus side
    output  logic   [31 : 0]    addr_m,     // address
    output  logic   [0  : 0]    we_m,       // write enable
    output  logic   [31 : 0]    wd_m,       // write data
    output  logic   [1  : 0]    size_m,     // tr size
    input   logic   [31 : 0]    rd_m        // read data
);

    dma_cr_v                cr_out;
    logic       [31 : 0]    src_addr;
    logic       [31 : 0]    dst_addr;
    logic       [3  : 0]    cnt;
    logic       [31 : 0]    int_buf;
    logic       [31 : 0]    int_buf_s;
    logic       [31 : 0]    int_buf_l;
    logic       [0  : 0]    dma_phase;

    logic       [0  : 0]    cr_we;
    logic       [0  : 0]    src_a_we;
    logic       [0  : 0]    dst_a_we;

    logic       [31 : 0]    src_addr_fsm;
    logic       [31 : 0]    dst_addr_fsm;

    logic       [2  : 0]    src_addr_step;    
    logic       [2  : 0]    dst_addr_step;    

    logic       [0  : 0]    idle2wb;
    logic       [0  : 0]    wb2tr;
    logic       [0  : 0]    tr2idle;

    enum
    logic       [1  : 0]    { IDLE_s , WB_s , TR_s } state, next_state;

    assign cr_we    = we_find( we , addr , DMA_CR      );
    assign src_a_we = we_find( we , addr , DMA_SRC_ADR );
    assign dst_a_we = we_find( we , addr , DMA_DST_ADR );

    assign addr_m = dma_phase ? dst_addr_fsm : src_addr_fsm;
    assign size_m = dma_phase ? cr_out.dst_size : cr_out.src_size;
    assign wd_m   = int_buf_l;

    assign idle2wb = dma_req;
    assign wb2tr   = bus_grant;
    assign tr2idle = ( cnt == cr_out.cnt ) && ( ! dma_phase );

    always_ff @(posedge clk)
        if( ! rstn )
            state <= IDLE_s;
        else
            state <= next_state;

    always_comb
    begin
        next_state = state;
        case( state )
            IDLE_s  : next_state = idle2wb ? WB_s   : state;
            WB_s    : next_state = wb2tr   ? TR_s   : state;
            TR_s    : next_state = tr2idle ? IDLE_s : state;
            default : ;
        endcase
    end

    always_comb
    begin
        src_addr_step = '0;
        case( cr_out.src_size )
            DMA_B   : src_addr_step = 3'h1;
            DMA_HW  : src_addr_step = 3'h2;
            DMA_W   : src_addr_step = 3'h4;
            default : ;
        endcase
    end

    always_comb
    begin
        dst_addr_step = '0;
        case( cr_out.dst_size )
            DMA_B   : dst_addr_step = 3'h1;
            DMA_HW  : dst_addr_step = 3'h2;
            DMA_W   : dst_addr_step = 3'h4;
            default : ;
        endcase
    end

    always_ff @(posedge clk)
        if( ! rstn )
        begin
            src_addr_fsm <= '0;
            dst_addr_fsm <= '0;
            cnt <= '0;
            int_buf <= '0;
            dma_phase <= '0;
            bus_req <= '0;
            bus_lock <= '0;
            we_m <= '0;
        end
        else
        begin
            case( state )
                IDLE_s  :
                begin
                    int_buf <= '0;
                    dma_phase <= '0;
                    cnt <= '0;
                    bus_req <= '0;
                    bus_lock <= '0;
                    we_m <= '0;
                    if( idle2wb )
                    begin
                        src_addr_fsm <= src_addr;
                        dst_addr_fsm <= dst_addr;
                        bus_req <= '1;
                        bus_lock <= '1;
                    end
                end
                WB_s    :
                begin   
                    if( wb2tr )
                        bus_req <= '0;
                end
                TR_s    :
                begin
                    dma_phase <= ~ dma_phase;
                    we_m <= ~ we_m;
                    cnt <= dma_phase ? cnt + 1'b1 : cnt;
                    src_addr_fsm <= ( ( ! dma_phase ) && ( cr_out.inc_src_a ) ) ? src_addr_fsm + src_addr_step : src_addr_fsm;
                    dst_addr_fsm <= ( (   dma_phase ) && ( cr_out.inc_dst_a ) ) ? dst_addr_fsm + dst_addr_step : dst_addr_fsm;
                    int_buf <= ~ dma_phase ? int_buf_s : int_buf;
                end
                default : ;
            endcase
        end

    always_comb
    begin
        int_buf_s = rd_m;
        case( src_addr_fsm[0 +: 2] )
            2'b00   : int_buf_s = rd_m >>  0;
            2'b01   : int_buf_s = rd_m >>  8;
            2'b10   : int_buf_s = rd_m >> 16;
            2'b11   : int_buf_s = rd_m >> 24;
        endcase
    end

    always_comb
    begin
        int_buf_l = int_buf;
        case( dst_addr_fsm[0 +: 2] )
            2'b00   : int_buf_l = int_buf <<  0;
            2'b01   : int_buf_l = int_buf <<  8;
            2'b10   : int_buf_l = int_buf << 16;
            2'b11   : int_buf_l = int_buf << 24;
        endcase
    end

    always_comb
    begin 
        rd = '0;
        case( addr )
            DMA_CR      : rd = { '0 , cr_out   };
            DMA_SRC_ADR : rd = { '0 , src_addr };
            DMA_DST_ADR : rd = { '0 , dst_addr };
        endcase
    end

    reg_we  #( 10 ) cr_ff       ( clk , rstn , cr_we    , wd , cr_out   );
    reg_we  #( 32 ) src_addr_ff ( clk , rstn , src_a_we , wd , src_addr );
    reg_we  #( 32 ) dst_addr_ff ( clk , rstn , dst_a_we , wd , dst_addr );

    function automatic logic [0 : 0] we_find(logic [0 : 0] we_in, logic [31 : 0] addr_in, logic [31 : 0] addr_v);
        return we_in && ( addr_in == addr_v );
    endfunction : we_find

endmodule : dma
