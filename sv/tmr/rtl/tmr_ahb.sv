/*
*  File            :   tmr_ahb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.17
*  Language        :   SystemVerilog
*  Description     :   This is ahb TMR module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module tmr_ahb
#(
    parameter                   tmr_w = 8
)(
    // clock and reset
    input   logic   [0  : 0]    hclk,       // ahb clock
    input   logic   [0  : 0]    hresetn,    // ahb reset
    // bus side
    input   logic   [4  : 0]    haddr,      // ahb slave address
    output  logic   [31 : 0]    hrdata,     // ahb slave read data
    input   logic   [31 : 0]    hwdata,     // ahb slave write data
    input   logic   [0  : 0]    hwrite,     // ahb slave write signal
    input   logic   [1  : 0]    htrans,     // ahb slave transfer control signal
    input   logic   [2  : 0]    hsize,      // ahb slave size signal
    input   logic   [2  : 0]    hburst,     // ahb slave burst signal
    output  logic   [1  : 0]    hresp,      // ahb slave response signal
    output  logic   [0  : 0]    hready,     // ahb slave ready signal
    input   logic   [0  : 0]    hsel,       // ahb slave select signal
    // IRQ
    output  logic   [0  : 0]    irq,        // interrupt request
    // TMR side
    input   logic   [0  : 0]    tmr_in,     // TMR input
    output  logic   [0  : 0]    tmr_out     // TMR output
);

    logic   [0  : 0]    tr_req;
    logic   [0  : 0]    we_req;
    logic   [4  : 0]    addr;
    logic   [0  : 0]    we;
    logic   [31 : 0]    wd;
    logic   [31 : 0]    rd;

    assign hresp = '0;
    assign tr_req = hsel && (htrans != '0);
    assign we_req = tr_req && hwrite;
    assign wd = hwdata;
    assign hrdata = rd;
    assign hready = '1;

    reg_we  #( 5 )  addr_ff     ( hclk , hresetn , '1 , haddr  , addr );
    reg_we  #( 1 )  we_ff       ( hclk , hresetn , '1 , we_req , we   );


    tmr
    #(
        .tmr_w      ( tmr_w     )
    )
    tmr_0
    (
        // clock and reset
        .clk        ( hclk      ),  // clock
        .rstn       ( hresetn   ),  // reset
        // bus side
        .addr       ( addr      ),  // address
        .we         ( we        ),  // write enable
        .wd         ( wd        ),  // write data
        .rd         ( rd        ),  // read data
        // IRQ
        .irq        ( irq       ),  // interrupt request
        // TMR side
        .tmr_in     ( tmr_in    ),  // TMR input
        .tmr_out    ( tmr_out   )   // TMR output
    );

endmodule : tmr_ahb
