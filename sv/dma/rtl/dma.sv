/*
*  File            :   dma.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.19
*  Language        :   SystemVerilog
*  Description     :   This is DMA module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "dma.svh"

module dma
(
    // clock and reset
    input   logic   [0  : 0]    clk,        // clock
    input   logic   [0  : 0]    rstn,       // reset
    // bus side
    input   logic   [3  : 0]    addr,       // address
    input   logic   [0  : 0]    we,         // write enable
    input   logic   [31 : 0]    wd,         // write data
    output  logic   [31 : 0]    rd,         // read data
    // REQ
    input   logic   [0  : 0]    dma_req,    // dma request
    // DMA master side side
    output  logic   [0  : 0]    bus_req,    // bus request
    output  logic   [0  : 0]    bus_lock,   // bus lock
    input   logic   [0  : 0]    bus_grant,  // bus grant
    output  logic   [31 : 0]    addr_m,     // address
    output  logic   [0  : 0]    we_m,       // write enable
    output  logic   [31 : 0]    wd_m,       // write data
    output  logic   [3  : 0]    byte_en,    // byte enable
    input   logic   [31 : 0]    rd_m        // read data
);

    dma_cr_v                cr_out;
    logic       [31 : 0]    src_addr;
    logic       [31 : 0]    dst_addr;

    logic       [0  : 0]    cr_we;
    logic       [0  : 0]    src_a_we;
    logic       [0  : 0]    dst_a_we;

    logic       [31 : 0]    src_addr_fsm;
    logic       [31 : 0]    dst_addr_fsm;

    assign bus_req = '0;
    assign bus_lock = '0;

    always_comb
    begin 
        rd = '0;
        case( addr )
            DMA_CR      : rd = { '0 , cr_out   };
            DMA_SRC_ADR : rd = { '0 , src_addr };
            DMA_DST_ADR : rd = { '0 , dst_addr };
        endcase
    end

    assign cr_we    = we_find( we , addr , DMA_CR      );
    assign src_a_we = we_find( we , addr , DMA_SRC_ADR );
    assign dst_a_we = we_find( we , addr , DMA_DST_ADR );

    reg_we  #( 10 ) cr_ff       ( clk , rstn , cr_we    , wd , cr_out   );
    reg_we  #( 32 ) src_addr_ff ( clk , rstn , src_a_we , wd , src_addr );
    reg_we  #( 32 ) dst_addr_ff ( clk , rstn , dst_a_we , wd , dst_addr );

    function automatic logic [0 : 0] we_find(logic [0 : 0] we_in, logic [31 : 0] addr_in, logic [31 : 0] addr_v);
        return we_in && ( addr_in == addr_v );
    endfunction : we_find

endmodule : dma
