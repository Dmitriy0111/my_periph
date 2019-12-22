/*
*  File            :   simple_router.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.20
*  Language        :   SystemVerilog
*  Description     :   This is simple arbiter module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module simple_router
#(
    parameter                               slv_c = 2
)(
    // clock and reset
    input   logic                [0  : 0]   clk,        // clock
    input   logic                [0  : 0]   rstn,       // reset
    //
    input   logic   [slv_c-1 : 0][31 : 0]   addr_am,    // address map
    // master side
    input   logic                [31 : 0]   addr,       // addr
    input   logic                [0  : 0]   we,         // write enable data
    input   logic                [31 : 0]   wd,         // write data
    output  logic                [31 : 0]   rd,         // read data
    input   logic                [1  : 0]   size,       // data size
    // slave side
    output  logic   [slv_c-1 : 0][31 : 0]   addr_s,     // addr
    output  logic   [slv_c-1 : 0][0  : 0]   we_s,       // write enable data
    output  logic   [slv_c-1 : 0][31 : 0]   wd_s,       // write data
    input   logic   [slv_c-1 : 0][31 : 0]   rd_s,       // read data
    output  logic   [slv_c-1 : 0][1  : 0]   size_s      // data size

);

    logic   [slv_c-1 : 0]   sel;

    genvar router_i;

    assign we_s = { slv_c { we } } & sel; 

    generate
        for( router_i = 0 ; router_i < slv_c ; router_i++ )
        begin : gen_router
            assign addr_s [router_i] = addr;
            assign wd_s   [router_i] = wd;
            assign size_s [router_i] = size;
        end
    endgenerate

    simple_dec
    #(
        .slv_c      ( slv_c     )
    )
    simple_dec_0
    (
        .addr_am    ( addr_am   ),  // address mask
        .addr       ( addr      ),  // address
        .sel        ( sel       )   // select
    );

    simple_mux
    #(
        .slv_c      ( slv_c     )
    )
    simple_mux_0
    (
        .sel        ( sel       ),  // select
        // slave side
        .rd_s       ( rd_s      ),
        // master side
        .rd         ( rd        )
    );

endmodule : simple_router
