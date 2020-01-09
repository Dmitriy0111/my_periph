/* 
*  File            :   regs.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.04.24
*  Language        :   SystemVerilog
*  Description     :   This is file with registers modules
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

// simple register with reset and clock 
module reg_s
#(
    parameter                   dw = 1
)(
    input   logic   [0    : 0]  clk,        // clk
    input   logic   [0    : 0]  rstn,       // resetn
    input   logic   [dw-1 : 0]  pdi,        // input data
    output  logic   [dw-1 : 0]  pdo         // output data
);

    always_ff @(posedge clk)
        if( ! rstn )
            pdo <= '0;
        else
            pdo <= pdi;

endmodule : reg_s

// register with write enable input
module reg_we
#(
    parameter                   dw = 1
)(
    input   logic   [0    : 0]  clk,        // clk
    input   logic   [0    : 0]  rstn,       // resetn
    input   logic   [0    : 0]  we,         // write enable
    input   logic   [dw-1 : 0]  pdi,        // input data
    output  logic   [dw-1 : 0]  pdo         // output data
);

    always_ff @(posedge clk)
        if( ! rstn )
            pdo <= '0;
        else if( we )
            pdo <= pdi;

endmodule : reg_we

// register with clr input
module reg_clr
#(
    parameter                   dw = 1
)(
    input   logic   [0    : 0]  clk,        // clk
    input   logic   [0    : 0]  rstn,       // resetn
    input   logic   [0    : 0]  clr,        // clear register
    input   logic   [dw-1 : 0]  pdi,        // input data
    output  logic   [dw-1 : 0]  pdo         // output data
);

    always_ff @(posedge clk)
    if( ! rstn )
        pdo <= '0;
    else
        pdo <= clr ? '0 : pdi;

endmodule : reg_clr

// register with clr and we input's
module reg_we_clr
#(
    parameter                   dw = 1
)(
    input   logic   [0    : 0]  clk,        // clk
    input   logic   [0    : 0]  rstn,       // resetn
    input   logic   [0    : 0]  we,         // write enable
    input   logic   [0    : 0]  clr,        // clear register
    input   logic   [dw-1 : 0]  pdi,        // input data
    output  logic   [dw-1 : 0]  pdo         // output data
);

    always_ff @(posedge clk)
        if( ! rstn )
            pdo <= '0;
        else if( we )
            pdo <= clr ? '0 : pdi;

endmodule : reg_we_clr
