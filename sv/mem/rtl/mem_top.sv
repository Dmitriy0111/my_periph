/*
*  File            :   mem.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.21
*  Language        :   SystemVerilog
*  Description     :   This is memory module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

import mem_pkg::*;

module mem_top
#(
    parameter                       depth = 8,
                                    a_w = $clog2(depth),
                                    d_w = 32,
                                    b_c = 4
)(
    // clock
    input   logic   [0     : 0]     clk,    // clock
    // bus side
    input   logic   [a_w-1 : 0]     addr,   // address
    input   logic   [b_c-1 : 0]     we,     // write enable
    input   logic   [d_w-1 : 0]     wd,     // write data
    output  logic   [d_w-1 : 0]     rd      // read data
);

    mem
    #(
        .depth      ( depth     ),
        .a_w        ( a_w       ),
        .d_w        ( d_w       ),
        .b_c        ( b_c       ),
        .mem_init   ( 1         ),
        .init_s     ( 8         ),
        .mem_v      ( mem_v     )
    )
    mem_0
    (
        // clock
        .clk        ( clk       ),  // clock
        // bus side
        .addr       ( addr      ),  // address
        .we         ( we        ),  // write enable
        .wd         ( wd        ),  // write data
        .rd         ( rd        )   // read data
    );

endmodule : mem_top
