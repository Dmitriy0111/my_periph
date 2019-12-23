/*
*  File            :   nf_apb_mux.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.23
*  Language        :   SystemVerilog
*  Description     :   This is apb multiplexor module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module apb_mux
#(
    parameter                                   slv_c = 4,
                                                a_w = 8
)(
    // clock and reset
    input   logic                [0     : 0]    pclk,       // pclock
    input   logic                [0     : 0]    presetn,    // presetn
    // sel side
    input   logic                [a_w-1 : 0]    paddr,      // apb address
    input   logic   [slv_c-1 : 0][a_w-1 : 0]    paddr_am,   // apb address mask
    // APB master side
    output  logic                [31    : 0]    prdata,     // apb read data
    input   logic                [0     : 0]    psel,       // apb select
    output  logic                [0     : 0]    pready,     // apb ready
    // APB slave side
    input   logic   [slv_c-1 : 0][31    : 0]    prdata_s,   // apb read data
    output  logic   [slv_c-1 : 0][0     : 0]    psel_s,     // apb select
    input   logic   [slv_c-1 : 0][0     : 0]    pready_s    // apb ready
);

    genvar apb_i;

    generate
        for( apb_i = 0 ; apb_i < slv_c ; apb_i++ )
        begin : gen_apb_mux
            always_comb
            begin
                psel_s[apb_i] = '0;
                casex( paddr )
                    paddr_am[apb_i] : psel_s[apb_i] = psel;
                    default         : ;
                endcase
            end
        end
    endgenerate

    always_comb
    begin
        prdata = ( psel_s != 0 ) ? prdata_s[sel_find(psel_s)]: '0;
        pready = ( psel_s != 0 ) ? pready_s[sel_find(psel_s)]: '1;
    end

    function automatic int sel_find([slv_c-1 : 0] psel_in);
        int i;
        for( i = 0 ; i < slv_c ; i++ )
            if(psel_in[i] == 1'b1)
                return i;
        return '0;
    endfunction : sel_find

endmodule : apb_mux
