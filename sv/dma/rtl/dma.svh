/*
*  File            :   dma.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.19
*  Language        :   SystemVerilog
*  Description     :   This is DMA constants
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef SVH__DMA
`define SVH__DMA

typedef enum logic [3 : 0]
{
    DMA_CR      = 4'h0,
    DMA_SRC_ADR = 4'h4,
    DMA_DST_ADR = 4'h8
} dma_e;

typedef enum logic [1 : 0]
{
    DMA_B   = 2'h0,
    DMA_HW  = 2'h1,
    DMA_W   = 2'h2
} size_e;

typedef struct packed
{
    logic   [2 : 0]     cnt;        // transmit counter
    logic   [1 : 0]     src_size;   // src_size
    logic   [1 : 0]     dst_size;   // src_size
    logic   [0 : 0]     inc_src_a;  // increment source addr
    logic   [0 : 0]     inc_dst_a;  // increment destination addr
    logic   [0 : 0]     line_en;    // req line enable
} dma_cr_v;

`endif // SVH__DMA
