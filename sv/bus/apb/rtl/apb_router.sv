/* 
*  File            :   apb_router.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.23
*  Language        :   SystemVerilog
*  Description     :   This is APB router module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module apb_router
#(
    parameter                                   slv_c = 2,
                                                a_w = 8
)(
    // clock and reset
    input   logic                [0     : 0]    pclk,           // pclk
    input   logic                [0     : 0]    presetn,        // presetn
    // APB master side
    input   logic   [slv_c-1 : 0][a_w-1 : 0]    paddr_am,       // apb master address mask
    input   logic                [a_w-1 : 0]    paddr,          // apb master address
    output  logic                [31    : 0]    prdata,         // apb master read data
    input   logic                [31    : 0]    pwdata,         // apb master write data
    input   logic                [0     : 0]    psel,           // apb master select
    input   logic                [0     : 0]    pwrite,         // apb master write
    input   logic                [0     : 0]    penable,        // apb master enable
    output  logic                [0     : 0]    pready,         // apb master ready
    // APB slave side
    output  logic   [slv_c-1 : 0][a_w-1 : 0]    paddr_s,        // apb slave address
    input   logic   [slv_c-1 : 0][31    : 0]    prdata_s,       // apb slave read data
    output  logic   [slv_c-1 : 0][31    : 0]    pwdata_s,       // apb slave write data
    output  logic   [slv_c-1 : 0][0     : 0]    psel_s,         // apb slave select
    output  logic   [slv_c-1 : 0][0     : 0]    pwrite_s,       // apb slave write
    output  logic   [slv_c-1 : 0][0     : 0]    penable_s,      // apb slave enable
    input   logic   [slv_c-1 : 0][0     : 0]    pready_s        // apb slave ready
);

    genvar apb_i;

    // generating wires for all slaves
    generate
        for( apb_i = 0 ; apb_i < slv_c ; apb_i++ )
        begin : apb_wires_gen
            assign paddr_s  [apb_i] = paddr;
            assign pwdata_s [apb_i] = pwdata;
            assign pwrite_s [apb_i] = pwrite;
            assign penable_s[apb_i] = penable;
        end
    endgenerate

    // creating one APB multiplexer module
    apb_mux
    #(
        .slv_c      ( slv_c     ),
        .a_w        ( a_w       )
    )
    apb_mux_0
    (
        // clock and reset
        .pclk       ( pclk      ),  // pclock
        .presetn    ( presetn   ),  // presetn
        // sel side
        .paddr      ( paddr     ),  // apb address
        .paddr_am   ( paddr_am  ),  // apb address mask
        // APB master side
        .prdata     ( prdata    ),  // apb read data
        .psel       ( psel      ),  // apb select
        .pready     ( pready    ),  // apb ready
        // APB slave side
        .prdata_s   ( prdata_s  ),  // apb read data
        .psel_s     ( psel_s    ),  // apb select
        .pready_s   ( pready_s  )   // apb ready
    );

endmodule : apb_router
