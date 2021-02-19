/* 
*  File            :   regs.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.04.24
*  Language        :   SystemVerilog
*  Description     :   This is file with registers modules
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

///////////////////////////////////////////////////////////////////////////////
// reg                                                                       //
///////////////////////////////////////////////////////////////////////////////

module reg_sv
#(
    parameter                       DATA_W = 1,
                                    RST_T = "SYNC",
                                    RST_P = "LOW"
)(
    // Clock and reset
    input   logic   [0        : 0]  CLK,
    input   logic   [0        : 0]  RST,
    // Data and control
    input   logic   [DATA_W-1 : 0]  PDI,
    output  logic   [DATA_W-1 : 0]  PDO
);
    localparam  this_rst_val = RST_P == "HIGH" ? '1 : '0;

    generate 
        if ( (RST_T == "ASYNC") && (RST_P == "LOW") )
        begin : gen_async_low
            always_ff @(posedge CLK, negedge RST)
                if( RST == this_rst_val )
                    PDO <= '0;
                else
                    PDO <= PDI;
        end
        if ( (RST_T == "ASYNC") && (RST_P == "HIGH") )
        begin : gen_async_high
            always_ff @(posedge CLK, posedge RST)
                if( RST == this_rst_val )
                    PDO <= '0;
                else
                    PDO <= PDI;
        end
        if (RST_T == "SYNC")
        begin : gen_sync
            always_ff @(posedge CLK)
                if( RST == this_rst_val )
                    PDO <= '0;
                else
                    PDO <= PDI;
        end
    endgenerate

endmodule : reg_sv

///////////////////////////////////////////////////////////////////////////////
// reg_we                                                                    //
///////////////////////////////////////////////////////////////////////////////

module reg_we_sv
#(
    parameter                       DATA_W = 1,
                                    RST_T = "SYNC",
                                    RST_P = "LOW"
)(
    // Clock and reset
    input   logic   [0        : 0]  CLK,
    input   logic   [0        : 0]  RST,
    // Data and control
    input   logic   [0        : 0]  WE, 
    input   logic   [DATA_W-1 : 0]  PDI,
    output  logic   [DATA_W-1 : 0]  PDO
);
    localparam  this_rst_val = RST_P == "HIGH" ? '1 : '0;

    generate 
        if ( (RST_T == "ASYNC") && (RST_P == "LOW") )
        begin : gen_async_low
            always_ff @(posedge CLK, negedge RST)
                if( RST == this_rst_val )
                    PDO <= '0;
                else if( WE )
                    PDO <= PDI;
        end
        if ( (RST_T == "ASYNC") && (RST_P == "HIGH") )
        begin : gen_async_high
            always_ff @(posedge CLK, posedge RST)
                if( RST == this_rst_val )
                    PDO <= '0;
                else if( WE )
                    PDO <= PDI;
        end
        if (RST_T == "SYNC")
        begin : gen_sync
            always_ff @(posedge CLK)
                if( RST == this_rst_val )
                    PDO <= '0;
                else if( WE )
                    PDO <= PDI;
        end
    endgenerate

endmodule : reg_we_sv

///////////////////////////////////////////////////////////////////////////////
// reg_clr                                                                   //
///////////////////////////////////////////////////////////////////////////////

module reg_clr_sv
#(
    parameter                       DATA_W = 1,
                                    RST_T = "SYNC",
                                    RST_P = "LOW"
)(
    // Clock and reset
    input   logic   [0        : 0]  CLK,
    input   logic   [0        : 0]  RST,
    // Data and control
    input   logic   [0        : 0]  CLR,
    input   logic   [DATA_W-1 : 0]  PDI,
    output  logic   [DATA_W-1 : 0]  PDO
);
    localparam  this_rst_val = RST_P == "HIGH" ? '1 : '0;

    generate 
        if ( (RST_T == "ASYNC") && (RST_P == "LOW") )
        begin : gen_async_low
            always_ff @(posedge CLK, negedge RST)
                if( RST == this_rst_val )
                    PDO <= '0;
                else
                    PDO <= CLR ? '0 : PDI;
        end
        if ( (RST_T == "ASYNC") && (RST_P == "HIGH") )
        begin : gen_async_high
            always_ff @(posedge CLK, posedge RST)
                if( RST == this_rst_val )
                    PDO <= '0;
                else
                    PDO <= CLR ? '0 : PDI;
        end
        if (RST_T == "SYNC")
        begin : gen_sync
            always_ff @(posedge CLK)
                if( RST == this_rst_val )
                    PDO <= '0;
                else
                    PDO <= CLR ? '0 : PDI;
        end
    endgenerate

endmodule : reg_clr_sv

///////////////////////////////////////////////////////////////////////////////
// reg_we_clr                                                                //
///////////////////////////////////////////////////////////////////////////////

module reg_we_clr_sv
#(
    parameter                       DATA_W = 1,
                                    RST_T = "SYNC",
                                    RST_P = "LOW"
)(
    // Clock and reset
    input   logic   [0        : 0]  CLK,
    input   logic   [0        : 0]  RST,
    // Data and control
    input   logic   [0        : 0]  WE,
    input   logic   [0        : 0]  CLR,
    input   logic   [DATA_W-1 : 0]  PDI,
    output  logic   [DATA_W-1 : 0]  PDO
);
    localparam  this_rst_val = RST_P == "HIGH" ? '1 : '0;

    generate 
        if ( (RST_T == "ASYNC") && (RST_P == "LOW") )
        begin : gen_async_low
            always_ff @(posedge CLK, negedge RST)
                if( RST == this_rst_val )
                    PDO <= '0;
                else if( WE )
                    PDO <= CLR ? '0 : PDI;
        end
        if ( (RST_T == "ASYNC") && (RST_P == "HIGH") )
        begin : gen_async_high
            always_ff @(posedge CLK, posedge RST)
                if( RST == this_rst_val )
                    PDO <= '0;
                else if( WE )
                    PDO <= CLR ? '0 : PDI;
        end
        if (RST_T == "SYNC")
        begin : gen_sync
            always_ff @(posedge CLK)
                if( RST == this_rst_val )
                    PDO <= '0;
                else if( WE )
                    PDO <= CLR ? '0 : PDI;
        end
    endgenerate

endmodule : reg_we_clr_sv
