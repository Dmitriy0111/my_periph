/*
*  File            :   ahb_mux.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.18
*  Language        :   SystemVerilog
*  Description     :   This is ahb multiplexor module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module ahb_mux
#(
    parameter                               slv_c = 4
)(
    // clock and reset
    input   logic   [slv_c-1 : 0]           hsel_ff,
    // slave side
    input   logic   [slv_c-1 : 0][31 : 0]   hrdata_s,
    input   logic   [slv_c-1 : 0][1  : 0]   hresp_s,
    input   logic   [slv_c-1 : 0][0  : 0]   hready_s,
    // master side
    output  logic                [31 : 0]   hrdata,
    output  logic                [1  : 0]   hresp,
    output  logic                [0  : 0]   hready
);

    always_comb
    begin
        hrdata = ( hsel_ff != 0 ) ? hrdata_s[sel_find(hsel_ff)] : '0;
        hresp  = ( hsel_ff != 0 ) ? hresp_s [sel_find(hsel_ff)] : 2'b01;
        hready = ( hsel_ff != 0 ) ? hready_s[sel_find(hsel_ff)] : '1;
    end

    function automatic int sel_find([slv_c-1 : 0] hsel_in);
        int i;
        for( i = 0 ; i < slv_c ; i++ )
            if(hsel_in[i] == 1'b1)
                return i;
        return '0;
    endfunction : sel_find

endmodule : ahb_mux
