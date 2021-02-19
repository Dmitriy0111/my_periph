/*
*  File            :   gpio.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.06
*  Language        :   SystemVerilog
*  Description     :   This is GPIO module
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`include "gpio.svh"

module gpio_sv
#(
    parameter                       ADDR_W = 32,
                                    DATA_W = 32,
                                    GPIO_W = 8,
                                    RST_T = "ASYNC",
                                    RST_P = "LOW",
                                    IRQ_U = 1,
                                    ALT_U = 1
)(
    // Clock and reset
    input   logic   [0        : 0]  CLK,    // clock
    input   logic   [0        : 0]  RST,    // reset
    // Simple interface
    input   logic   [ADDR_W-1 : 0]  ADDR,   // address
    input   logic   [0        : 0]  WE,     // write enable
    input   logic   [DATA_W-1 : 0]  WD,     // write data
    output  logic   [DATA_W-1 : 0]  RD,     // read data
    // IRQ
    output  logic   [0        : 0]  IRQ,    // interrupt request
    // Alternative
    output  logic   [GPIO_W-1 : 0]  ALT_i,
    input   logic   [GPIO_W-1 : 0]  ALT_o,
    input   logic   [GPIO_W-1 : 0]  ALT_d,
    // GPIO side
    input   logic   [GPIO_W-1 : 0]  GPI,    // GPIO input
    output  logic   [GPIO_W-1 : 0]  GPO,    // GPIO output
    output  logic   [GPIO_W-1 : 0]  GPD     // GPIO direction
);
    // internal regs
    logic   [GPIO_W-1 : 0]  gpi_int_0;
    logic   [GPIO_W-1 : 0]  gpi_int_1;
    logic   [GPIO_W-1 : 0]  gpi_int_2;
    logic   [GPIO_W-1 : 0]  gpo_int;
    logic   [GPIO_W-1 : 0]  gpd_int;
    logic   [GPIO_W-1 : 0]  alt;
    logic   [GPIO_W-1 : 0]  irq_m;
    logic   [GPIO_W-1 : 0]  irq_t;
    logic   [GPIO_W-1 : 0]  irq_v;
    logic   [GPIO_W-1 : 0]  cap;
    logic   [GPIO_W-1 : 0]  irq_v_f;
    // irqs events
    logic   [GPIO_W-1 : 0]  pos_event;
    logic   [GPIO_W-1 : 0]  neg_event;
    logic   [GPIO_W-1 : 0]  hi_event;
    logic   [GPIO_W-1 : 0]  lo_event;
    // write enable signals
    logic   [0        : 0]  gpo_we;
    logic   [0        : 0]  gpd_we;
    logic   [0        : 0]  alt_we;
    logic   [0        : 0]  irq_m_we;
    logic   [0        : 0]  irq_t_we;
    logic   [0        : 0]  irq_v_we;
    logic   [GPIO_W-1 : 0]  irq_v_we_f;
    logic   [0        : 0]  cap_we;

    genvar                  irq_i;
    genvar                  alt_i;

    generate
        if ( !ALT_U )
        begin : alt_n_gen
            assign ALT_i = '0;
            assign GPO = gpo_int;
            assign GPD = gpd_int;
        end
        
        if (  ALT_U )
        begin : alt_gen
            assign ALT_i = GPI;
            for ( alt_i = 0 ; alt_i < GPIO_W ; alt_i++ )
            begin : alt_con_gen
                assign GPO[alt_i] = alt[alt_i] ? ALT_o[alt_i] : gpo_int[alt_i];
                assign GPD[alt_i] = alt[alt_i] ? ALT_d[alt_i] : gpd_int[alt_i];
            end
        end
    endgenerate
    // assign irq
    assign IRQ = IRQ_U ? | irq_v : '0;
    // assign write enable signals
    assign gpo_we   = find_we( ADDR , GPIO_GPO   , WE );
    assign gpd_we   = find_we( ADDR , GPIO_GPD   , WE );
    assign alt_we   = find_we( ADDR , GPIO_ALT   , WE );
    assign irq_m_we = find_we( ADDR , GPIO_IRQ_M , WE );
    assign irq_t_we = find_we( ADDR , GPIO_IRQ_T , WE );
    assign irq_v_we = find_we( ADDR , GPIO_IRQ_V , WE );
    assign cap_we   = find_we( ADDR , GPIO_CAP   , WE );
    // assign events
    assign pos_event = ( ~ gpi_int_2 ) & (   gpi_int_1 ) & irq_m & (   irq_t ) & (   cap );
    assign neg_event = (   gpi_int_2 ) & ( ~ gpi_int_1 ) & irq_m & (   irq_t ) & ( ~ cap );
    assign hi_event  = ( ~ gpi_int_2 ) &                   irq_m & ( ~ irq_t ) & (   cap );
    assign lo_event  = (   gpi_int_2 ) &                   irq_m & ( ~ irq_t ) & ( ~ cap );

    assign irq_v_we_f = pos_event | neg_event | hi_event | lo_event | { GPIO_W {irq_v_we} };

    always_comb
    begin
        RD = { '0 , IRQ_U ? gpi_int_2 :gpi_int_0 };
        casex( ADDR[0 +: 5] )
            GPIO_GPI    : RD = { '0 , IRQ_U ? gpi_int_2 :gpi_int_0 };
            GPIO_GPO    : RD = { '0 , gpo_int   };
            GPIO_GPD    : RD = { '0 , gpd_int   };
            GPIO_ALT    : RD = { '0 , ALT_U ? alt   : gpi_int_0 };
            GPIO_IRQ_M  : RD = { '0 , IRQ_U ? irq_m : gpi_int_0 };
            GPIO_IRQ_T  : RD = { '0 , IRQ_U ? irq_t : gpi_int_0 };
            GPIO_CAP    : RD = { '0 , IRQ_U ? cap   : gpi_int_0 };
            GPIO_IRQ_V  : RD = { '0 , IRQ_U ? irq_v : gpi_int_0 };
            default     : RD = { '0 , IRQ_U ? gpi_int_2 :gpi_int_0 };
        endcase
    end

    reg_we_sv   #( GPIO_W, RST_T, RST_P )
    gpo_reg     ( CLK, RST, gpo_we, WD[GPIO_W-1 : 0], gpo_int);

    reg_we_sv   #( GPIO_W, RST_T, RST_P )
    gpd_reg     ( CLK, RST, gpd_we, WD[GPIO_W-1 : 0], gpd_int);

    generate
        if( ALT_U )
        begin : gen_alt_reg
            reg_we_sv   #( GPIO_W, RST_T, RST_P )
            alt_reg     ( CLK, RST, alt_we, WD[GPIO_W-1 : 0], alt);
        end
    endgenerate

    reg_we_sv   #( GPIO_W, RST_T, RST_P )
    gpi_0_reg   ( CLK, RST, '1, GPI, gpi_int_0);

    generate
        if ( IRQ_U )
        begin : irq_gen 
            reg_we_sv   #( GPIO_W, RST_T, RST_P )
            gpi_1_reg   ( CLK, RST, '1, gpi_int_0, gpi_int_1);

            reg_we_sv   #( GPIO_W, RST_T, RST_P )
            gpi_2_reg   ( CLK, RST, '1, gpi_int_1, gpi_int_2);

            reg_we_sv   #( GPIO_W, RST_T, RST_P )
            irq_m_reg   ( CLK, RST, irq_m_we, WD[GPIO_W-1 : 0], irq_m);

            reg_we_sv   #( GPIO_W, RST_T, RST_P )
            irq_t_reg   ( CLK, RST, irq_t_we, WD[GPIO_W-1 : 0], irq_t);

            reg_we_sv   #( GPIO_W, RST_T, RST_P )
            cap_reg     ( CLK, RST, cap_we, WD[GPIO_W-1 : 0], cap);

            for ( irq_i = 0 ; irq_i < GPIO_W ; irq_i++ )
            begin : irq_reg_gen
                assign irq_v_f[irq_i] =  pos_event[irq_i] | neg_event[irq_i] | hi_event[irq_i] | lo_event[irq_i] ? '1 : WD[irq_i];

                reg_we_sv   #( 1, RST_T, RST_P )
                irq_v_reg   ( CLK, RST, irq_v_we_f[irq_i], irq_v_f[irq_i], irq_v[irq_i]);
            end
        end
    endgenerate

    function automatic logic [0 : 0] find_we(logic [31 : 0] addr_in, logic [31 : 0] addr_v, logic [0 : 0] we_in);
        return we_in && ( addr_in == addr_v );
    endfunction : find_we

endmodule : gpio_sv
