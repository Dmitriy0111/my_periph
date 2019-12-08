/* 
*  File            :   sync.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.04.24
*  Language        :   SystemVerilog
*  Description     :   This is sync chain
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module sync
#(
    parameter                   sync_w = 2,
                                dw = 8
)(
    input   logic   [0    : 0]  clk,
    input   logic   [0    : 0]  rstn,
    input   logic   [dw-1 : 0]  pdi,
    output  logic   [dw-1 : 0]  pdo
);

    logic   [sync_w : 0][dw-1 : 0]  sync_chain;

    assign sync_chain[0] = pdi;
    assign pdo = sync_chain[sync_w];

    genvar  sync_i;

    generate
        for(sync_i=0 ; sync_i<sync_w ; sync_i++)
        begin : gen_sync_chain
            reg_s   #( dw )  reg_s_  ( clk, rstn, sync_chain[sync_i], sync_chain[sync_i+1] );
        end
    endgenerate

endmodule : sync
