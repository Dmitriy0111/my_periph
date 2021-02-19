/*
*  File            :   simple_dec.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.20
*  Language        :   SystemVerilog
*  Description     :   This is decoder module
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

module simple_dec
#(
    parameter                               slv_c = 4
)(
    input   logic   [slv_c-1 : 0][31 : 0]   addr_am,    // address mask
    input   logic                [31 : 0]   addr,       // address
    output  logic   [slv_c-1 : 0]           sel         // select
);

    genvar dec_i;

    generate
        for( dec_i = 0 ; dec_i < slv_c ; dec_i++ )
        begin : gen_dec
            always_comb
            begin
                sel[dec_i] = '0;
                casex( addr )
                    addr_am[dec_i]  : sel[dec_i] = '1;
                    default         : ;
                endcase
            end
        end
    endgenerate

endmodule : simple_dec
