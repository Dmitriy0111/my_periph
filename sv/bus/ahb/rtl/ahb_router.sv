/*
*  File            :   ahb_router.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.18
*  Language        :   SystemVerilog
*  Description     :   This is ahb router module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module ahb_router
#(
    parameter                               slv_c = 4
)(
    // clock and reset
    input   logic                [0  : 0]   hclk,       // ahb clock
    input   logic                [0  : 0]   hresetn,    // ahb reset
    // Master side
    input   logic   [slv_c-1 : 0][31 : 0]   haddr_am,   // ahb master address mask
    input   logic                [31 : 0]   haddr,      // ahb master address
    output  logic                [31 : 0]   hrdata,     // ahb master read data
    input   logic                [31 : 0]   hwdata,     // ahb master write data
    input   logic                [0  : 0]   hwrite,     // ahb master write signal
    input   logic                [1  : 0]   htrans,     // ahb master transfer control signal
    input   logic                [2  : 0]   hsize,      // ahb master size signal
    input   logic                [2  : 0]   hburst,     // ahb master burst signal
    output  logic                [1  : 0]   hresp,      // ahb master response signal
    output  logic                [0  : 0]   hready,     // ahb master ready signal
    // Slaves side
    output  logic   [slv_c-1 : 0][31 : 0]   haddr_s,    // ahb slave address
    input   logic   [slv_c-1 : 0][31 : 0]   hrdata_s,   // ahb slave read data
    output  logic   [slv_c-1 : 0][31 : 0]   hwdata_s,   // ahb slave write data
    output  logic   [slv_c-1 : 0][0  : 0]   hwrite_s,   // ahb slave write signal
    output  logic   [slv_c-1 : 0][1  : 0]   htrans_s,   // ahb slave transfer control signal
    output  logic   [slv_c-1 : 0][2  : 0]   hsize_s,    // ahb slave size signal
    output  logic   [slv_c-1 : 0][2  : 0]   hburst_s,   // ahb slave burst signal
    input   logic   [slv_c-1 : 0][1  : 0]   hresp_s,    // ahb slave response signal
    input   logic   [slv_c-1 : 0][0  : 0]   hready_s,   // ahb slave ready signal
    output  logic   [slv_c-1 : 0][0  : 0]   hsel_s      // ahb slave select signal
);

    logic   [slv_c-1 : 0]   hsel_ff;
    logic   [slv_c-1 : 0]   hsel;

    genvar ahb_i;

    generate
        for( ahb_i = 0 ; ahb_i < slv_c ; ahb_i++ )
        begin : gen_ahb_router
            assign haddr_s  [ahb_i] = haddr;
            assign hwdata_s [ahb_i] = hwdata;
            assign hwrite_s [ahb_i] = hwrite;
            assign htrans_s [ahb_i] = htrans;
            assign hsize_s  [ahb_i] = hsize;
            assign hburst_s [ahb_i] = hburst;
        end
    endgenerate

    assign hsel_s = hsel;

    reg_we  #( slv_c )  hsel_ff_ff  ( hclk , hresetn , hready , hsel , hsel_ff );
    // creating one ahb dec
    ahb_dec
    #(
        .slv_c      ( slv_c         )
    )
    ahb_dec_0
    (
        .haddr_am   ( haddr_am      ),
        .haddr      ( haddr         ),
        .hsel       ( hsel          )
    );
    // creating one ahb mux
    ahb_mux
    #(
        .slv_c      ( slv_c         )
    )
    ahb_mux_0
    (
        .hsel_ff    ( hsel_ff       ),
        // slave side
        .hrdata_s   ( hrdata_s      ),
        .hresp_s    ( hresp_s       ),
        .hready_s   ( hready_s      ),
        // master side
        .hrdata     ( hrdata        ),
        .hresp      ( hresp         ),
        .hready     ( hready        )
    );

endmodule : ahb_router
    