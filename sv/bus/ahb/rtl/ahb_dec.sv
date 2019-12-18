/*
*  File            :   ahb_dec.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.18
*  Language        :   SystemVerilog
*  Description     :   This is ahb decoder module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module ahb_dec
#(
    parameter                               slv_c = 4
)(
    input   logic   [slv_c-1 : 0][31 : 0]   haddr_am,   // ahb address mask
    input   logic                [31 : 0]   haddr,      // ahb address
    output  logic   [slv_c-1 : 0]           hsel        // ahb select
);

    genvar ahb_i;

    generate
        for( ahb_i = 0 ; ahb_i < slv_c ; ahb_i++ )
        begin : gen_ahb_dec
            always_comb
            begin
                hsel[ahb_i] = '0;
                casex( haddr )
                    haddr_am[ahb_i] : hsel[ahb_i] = '1;
                    default         : ;
                endcase
            end
        end
    endgenerate

endmodule : ahb_dec
