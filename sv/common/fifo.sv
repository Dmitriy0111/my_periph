/*
*  File            :   fifo.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.04
*  Language        :   SystemVerilog
*  Description     :   This is fifo module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module fifo
#(
    parameter                       depth = 64,
                                    data_w = 32
)(
    // clock and reset
    input   logic   [0        : 0]  clk,            // clock
    input   logic   [0        : 0]  rstn,           // reset
    // fifo write
    input   logic   [1        : 0]  fifo_lvl,       // fifo full level trigger
    input   logic   [0        : 0]  we,             // write enable
    input   logic   [data_w-1 : 0]  wd,             // write data
    output  logic   [0        : 0]  fifo_full,      // fifo full
    // fifo read
    input   logic   [0        : 0]  re,             // read enable
    output  logic   [data_w-1 : 0]  rd,             // read data
    output  logic   [0        : 0]  fifo_emp        // fifo empty
);

    logic   [data_w-1        : 0]   fifo_mem    [depth-1 : 0];

    logic   [$clog2(depth)-1 : 0]   wr_addr;
    logic   [$clog2(depth)-1 : 0]   rd_addr;
    logic   [$clog2(depth)   : 0]   fifo_c;

    assign rd = fifo_mem[rd_addr];
    
    assign fifo_emp = fifo_c == 0;

    always_comb
    begin
        fifo_full = '0;
        case( fifo_lvl )
            2'b00   : fifo_full = fifo_c == 1;
            2'b01   : fifo_full = fifo_c == (depth >> 2);
            2'b10   : fifo_full = fifo_c == (depth >> 1);
            2'b11   : fifo_full = fifo_c == depth;
        endcase
    end

    always_ff @(posedge clk)
        if( ! rstn )
            fifo_c <= '0;
        else if( (~we) && re )
            fifo_c <= fifo_c - 1'b1;
        else if( (~re) && we )
            fifo_c <= fifo_c + 1'b1;

    always_ff @(posedge clk)
        if( ! rstn )
            rd_addr <= '0;
        else if( re ) 
            rd_addr <= rd_addr + 1'b1;

    always_ff @(posedge clk)
        if( ! rstn )
            wr_addr <= '0;
        else if( we ) 
            wr_addr <= wr_addr + 1'b1;

    always_ff @(posedge clk)
        if( we ) 
            fifo_mem[wr_addr] <= wd;

endmodule : fifo
