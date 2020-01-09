/*
*  File            :   simple_mux.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.20
*  Language        :   SystemVerilog
*  Description     :   This is multiplexor module
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

module simple_mux
#(
    parameter                               slv_c = 4
)(
    input   logic   [slv_c-1 : 0]           sel,
    // slave side
    input   logic   [slv_c-1 : 0][31 : 0]   rd_s,
    // master side
    output  logic                [31 : 0]   rd
);

    always_comb
    begin
        rd = ( sel != 0 ) ? rd_s[sel_find(sel)] : '0;
    end

    function automatic int sel_find([slv_c-1 : 0] sel_in);
        int i;
        for( i = 0 ; i < slv_c ; i++ )
            if(sel_in[i] == 1'b1)
                return i;
        return '0;
    endfunction : sel_find

endmodule : simple_mux
