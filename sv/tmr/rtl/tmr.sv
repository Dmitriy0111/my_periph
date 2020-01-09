/*
*  File            :   tmr.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.17
*  Language        :   SystemVerilog
*  Description     :   This is TMR module
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`include "tmr.svh"

module tmr
#(
    parameter                   tmr_w = 8
)(  
    // clock and reset
    input   logic   [0  : 0]    clk,        // clock
    input   logic   [0  : 0]    rstn,       // reset
    // bus side
    input   logic   [4  : 0]    addr,       // address
    input   logic   [0  : 0]    we,         // write enable
    input   logic   [31 : 0]    wd,         // write data
    output  logic   [31 : 0]    rd,         // read data
    // IRQ
    output  logic   [0  : 0]    irq,        // interrupt request
    // TMR side
    input   logic   [0  : 0]    tmr_in,     // TMR input
    output  logic   [0  : 0]    tmr_out     // TMR output
);

    // internal regs
    logic   [tmr_w-1 : 0]   tmr_c;
    logic   [tmr_w-1 : 0]   tmr_re;
    logic   [0       : 0]   tmr_in_sync;
    logic   [0       : 0]   tmr_in_reg;
    logic   [0       : 0]   irq_v;
    logic   [0       : 0]   irq_v_in;
    tmr_cr_v                cr_out;

    // write enable signals
    logic   [0       : 0]   tmr_cr_we;
    logic   [0       : 0]   tmr_re_we;
    logic   [0       : 0]   tmr_ir_we;
    logic   [0       : 0]   tmr_ir_we_f;

    // assign write enable signals
    assign tmr_cr_we = we_find( we , addr , TMR_CR );
    assign tmr_re_we = we_find( we , addr , TMR_RE );
    assign tmr_ir_we = we_find( we , addr , TMR_IR );

    assign tmr_ir_we_f = tmr_ir_we || ( ( tmr_c == tmr_re ) && cr_out.tmr_ie);
    assign irq_v_in = ( ( tmr_c == tmr_re ) && cr_out.tmr_ie) ? '1 : wd;

    assign tmr_out = tmr_c <= tmr_re;

    assign irq = | irq_v;

    always_comb
    begin
        rd = { '0 , cr_out };
        casex( addr[0 +: 4] )
            TMR_CR      : rd = { '0 , cr_out };
            TMR_RE      : rd = { '0 , tmr_re };
            TMR_IR      : rd = { '0 , irq_v  };
            default     : ;
        endcase
    end

    always_ff @(posedge clk, negedge rstn)
        if( ! rstn )
            tmr_c <= '0;
        else
        begin
            if( cr_out.tmr_en )
            begin
                if( ( ! cr_out.tmr_ex ) || ( ( ! tmr_in_reg ) && tmr_in_sync && cr_out.tmr_ex ) )
                    tmr_c <= ( tmr_c == tmr_re ) && cr_out.tmr_r ? '0 : tmr_c + 1'b1;
            end
            else
                tmr_c <= '0;
        end

    sync    #( 2 , 1 ) sync_in      ( clk , rstn ,               tmr_in      , tmr_in_sync );
    reg_we  #( 1     ) tmr_in_ff    ( clk , rstn , '1          , tmr_in_sync , tmr_in_reg  );
    reg_we  #( 3     ) cr_ff        ( clk , rstn , tmr_cr_we   , wd          , cr_out      );
    reg_we  #( tmr_w ) re_ff        ( clk , rstn , tmr_re_we   , wd          , tmr_re      );
    reg_we  #( 1     ) irq_v_ff     ( clk , rstn , tmr_ir_we_f , irq_v_in    , irq_v       );

    function automatic logic [0 : 0] we_find(logic [0 : 0] we_in, logic [31 : 0] addr_in, logic [31 : 0] addr_v);
        return we_in && ( addr_in == addr_v );
    endfunction : we_find

endmodule : tmr
