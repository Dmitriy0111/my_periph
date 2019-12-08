/*
*  File            :   gpio.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.06
*  Language        :   SystemVerilog
*  Description     :   This is GPIO module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "gpio.svh"

module gpio
#(
    parameter                       gpio_w = 8
)(
    // clock and reset
    input   logic   [0        : 0]  clk,    // clock
    input   logic   [0        : 0]  rstn,   // reset
    // bus side
    input   logic   [4        : 0]  addr,   // address
    input   logic   [0        : 0]  we,     // write enable
    input   logic   [31       : 0]  wd,     // write data
    output  logic   [31       : 0]  rd,     // read data
    // interrupt
    output  logic   [0        : 0]  irq,    // interrupt
    // GPIO side
    input   logic   [gpio_w-1 : 0]  gpi,    // GPIO input
    output  logic   [gpio_w-1 : 0]  gpo,    // GPIO output
    output  logic   [gpio_w-1 : 0]  gpd     // GPIO direction
);
    // internal regs
    logic   [gpio_w-1 : 0]  gpi_sync;
    logic   [gpio_w-1 : 0]  gpio_i;
    logic   [gpio_w-1 : 0]  gpio_o;
    logic   [gpio_w-1 : 0]  gpio_d;
    logic   [gpio_w-1 : 0]  irq_m;
    logic   [gpio_w-1 : 0]  irq_v;
    logic   [gpio_w-1 : 0]  irq_v_wd;
    logic   [gpio_w-1 : 0]  cap;
    logic   [gpio_w-1 : 0]  posedge_cap;
    logic   [gpio_w-1 : 0]  negedge_cap;

    // write enable signals 
    logic   [0        : 0]  gpo_we;
    logic   [0        : 0]  gpd_we;
    logic   [0        : 0]  irq_m_we;
    logic   [0        : 0]  cap_we;
    logic   [gpio_w-1 : 0]  irq_v_we;
    logic   [gpio_w-1 : 0]  irq_v_we_f;

    genvar irq_i;

    // assign inputs/outputs
    assign gpo    = gpio_o;
    assign gpd    = gpio_d;
    // assign write enable signals
    assign gpo_we   = we_find( we, addr, GPIO_GPO   );
    assign gpd_we   = we_find( we, addr, GPIO_GPD   );
    assign irq_m_we = we_find( we, addr, GPIO_IRQ_M );
    assign cap_we   = we_find( we, addr, GPIO_CAP   );

    assign irq = |irq_v;

    always_comb
    begin
        rd = gpio_i;
        casex( addr[0 +: 5] )
            GPIO_GPI    : rd = gpio_i;
            GPIO_GPO    : rd = gpio_o;
            GPIO_GPD    : rd = gpio_d;
            GPIO_IRQ_M  : rd = irq_m;
            GPIO_CAP    : rd = cap;
            GPIO_IRQ_V  : rd = irq_v;
            default     : ;
        endcase
    end

    generate
        for(irq_i = 0 ; irq_i < gpio_w ; irq_i++ )
        begin : gen_irq_regs
            assign posedge_cap[irq_i] = (   gpi_sync[irq_i] ) && ( ~ gpio_i[irq_i] ) && irq_m[irq_i] && (   cap[irq_i] );
            assign negedge_cap[irq_i] = ( ~ gpi_sync[irq_i] ) && (   gpio_i[irq_i] ) && irq_m[irq_i] && ( ~ cap[irq_i] );
            assign irq_v_we[irq_i] = we_find( we, addr, GPIO_IRQ_V );
            assign irq_v_we_f[irq_i] = posedge_cap[irq_i] || negedge_cap[irq_i] || irq_v_we[irq_i];
            assign irq_v_wd[irq_i] =   posedge_cap[irq_i] || negedge_cap[irq_i] ? '1 : wd[irq_i];
            reg_we  #( 1 ) irq_v_reg  ( clk, rstn, irq_v_we_f[irq_i], irq_v_wd[irq_i], irq_v[irq_i] );
        end
    endgenerate

    sync    #( 2, gpio_w ) sync_in_chain    ( clk, rstn,           gpi            , gpi_sync );
    reg_we  #(    gpio_w ) gpio_i_reg       ( clk, rstn, '1      , gpi_sync       , gpio_i   );
    reg_we  #(    gpio_w ) gpio_o_reg       ( clk, rstn, gpo_we  , wd[0 +: gpio_w], gpio_o   );
    reg_we  #(    gpio_w ) gpio_d_reg       ( clk, rstn, gpd_we  , wd[0 +: gpio_w], gpio_d   );
    reg_we  #(    gpio_w ) irq_m_reg        ( clk, rstn, irq_m_we, wd[0 +: gpio_w], irq_m    );
    reg_we  #(    gpio_w ) cap_reg          ( clk, rstn, cap_we  , wd[0 +: gpio_w], cap      );

    function automatic logic [0 : 0] we_find(logic [0 : 0] we_in, logic [2 : 0] addr_in, logic [2 : 0] addr_v);
        return we_in && ( addr_in == addr_v );
    endfunction : we_find

endmodule : gpio
