/* 
*  File            :   uart.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.05
*  Language        :   SystemVerilog
*  Description     :   This is uart module with simple interface
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`include "uart.svh"

module uart
(
    // reset and clock
    input   logic   [0  : 0]    clk,        // clk
    input   logic   [0  : 0]    rstn,       // reset
    // simple interface
    input   logic   [4  : 0]    addr,       // address
    input   logic   [0  : 0]    re,         // read enable
    input   logic   [0  : 0]    we,         // write enable
    input   logic   [31 : 0]    wd,         // write data
    output  logic   [31 : 0]    rd,         // read data
    // IRQ
    output  logic   [0  : 0]    irq,        // interrupt request
    // UART side
    output  logic   [0  : 0]    uart_tx,    // UART tx wire
    input   logic   [0  : 0]    uart_rx     // UART rx wire
);

    // write/read enable signals 
    logic   [0  : 0]    uart_cr_we;     // UART control register write enable
    logic   [0  : 0]    uart_tx_we;     // UART transmitter register write enable
    logic   [0  : 0]    uart_rx_re;     // UART receiver register read enable
    logic   [0  : 0]    uart_dv_we;     // UART divider register write enable
    logic   [0  : 0]    irq_m_we;       // UART interrupt mask write enable
    logic   [0  : 0]    irq_v_we_si;    // UART interrupt vector write enable
    logic   [7  : 0]    irq_v_we_f;     // UART interrupt vector write enable final
    // uart transmitter other signals
    logic   [0  : 0]    tx_fifo_emp;    // transmitter fifo empty
    logic   [0  : 0]    tx_req;         // request transmit
    logic   [0  : 0]    next_tx;        // next transmittion
    // transmitter/receiver enable signals
    logic   [0  : 0]    rx_valid;       // receive valid
    //
    logic   [15 : 0]    dfr;           // "dividing frequency"
    logic   [7  : 0]    tx_data;        // transmitted data from fifo
    logic   [7  : 0]    rx_data;        // received data
    logic   [7  : 0]    rx_fifo_data;   // received data from fifo

    uart_cr_v           cr_in;
    uart_cr_v           cr_out;

    uart_irq_v          irq_v_in;
    uart_irq_v          irq_m;
    uart_irq_v          irq_v_we;
    uart_irq_v          irq_v_out;

    genvar              irq_i;

    // assign write enable signals
    assign uart_cr_we  = we_find( we , addr , UART_CR    );
    assign uart_tx_we  = we_find( we , addr , UART_TX_RX );
    assign uart_rx_re  = we_find( re , addr , UART_TX_RX );
    assign uart_dv_we  = we_find( we , addr , UART_DFR   );
    assign irq_m_we    = we_find( we , addr , UART_IRQ_M );
    assign irq_v_we_si = we_find( we , addr , UART_IRQ_V );

    assign tx_req = ! tx_fifo_emp;
    assign irq = | irq_v_out;
    
    assign irq_v_we_f = { 8 { irq_v_we_si } } | irq_v_we;

    assign irq_v_we.un = '0;
    assign irq_v_we.rff = ( cr_out.rx_full && irq_m.rff );
    assign irq_v_we.tfe = ( tx_fifo_emp    && irq_m.tfe );
    assign irq_v_we.rc  = ( rx_valid       && irq_m.rc  );
    assign irq_v_we.tc  = ( next_tx        && irq_m.tc  );

    generate
        for( irq_i = 0 ; irq_i < 8 ; irq_i++ )
        begin : gen_irq_v_in
            assign irq_v_in[irq_i] = irq_v_we[irq_i] ? '1 : wd[irq_i];
        end
    endgenerate

    assign cr_in = wd[7 : 0];

    // mux for routing one register value
    always_comb
    begin
        rd = { '0 , cr_out };
        case( addr )
            UART_CR     : rd = { '0 , cr_out       };
            UART_TX_RX  : rd = { '0 , rx_fifo_data };
            UART_DFR    : rd = { '0 , dfr          };
            UART_IRQ_M  : rd = { '0 , irq_m        };
            UART_IRQ_V  : rd = { '0 , irq_v_out    };
        endcase
    end
    // creating control and data registers
    reg_we  #(  1 )     tr_en_ff        ( clk , rstn , uart_cr_we    , cr_in.tr_en       , cr_out.tr_en       );
    reg_we  #(  1 )     rec_en_ff       ( clk , rstn , uart_cr_we    , cr_in.rec_en      , cr_out.rec_en      );
    reg_we  #(  2 )     fifo_tx_lvl_ff  ( clk , rstn , uart_cr_we    , cr_in.tx_fifo_lvl , cr_out.tx_fifo_lvl );
    reg_we  #(  2 )     fifo_rx_lvl_ff  ( clk , rstn , uart_cr_we    , cr_in.rx_fifo_lvl , cr_out.rx_fifo_lvl );
    reg_we  #( 16 )     div_ff          ( clk , rstn , uart_dv_we    , wd[15 : 0]        , dfr                );
    reg_we  #(  8 )     irq_m_ff        ( clk , rstn , irq_m_we      , wd[7  : 0]        , irq_m              );

    generate
        for( irq_i = 0 ; irq_i < uart_irq_v_w ; irq_i++ )
        begin : gen_irq_ff
            reg_we  #( 1 )  irq_ff  ( clk , rstn , irq_v_we_f[irq_i] , irq_v_in[irq_i] , irq_v_out[irq_i] );
        end
        for( irq_i = uart_irq_v_w ; irq_i < 8 ; irq_i++ )
        begin : gen_irq_oth_ff
            assign irq_v_out[irq_i] = '0;
        end
    endgenerate

    // creating one tx_fifo
    fifo
    #(
        .depth      ( 8                     ),
        .data_w     ( 8                     )
    )
    tx_fifo
    (
        // clock and reset
        .clk        ( clk                   ),  // clock
        .rstn       ( rstn                  ),  // reset
        // fifo write
        .fifo_lvl   ( cr_out.tx_fifo_lvl    ),  // fifo full level trigger
        .we         ( uart_tx_we            ),  // write enable
        .wd         ( wd                    ),  // write data
        .fifo_full  ( cr_out.tx_full        ),  // fifo full
        // fifo read
        .re         ( next_tx               ),  // read enable
        .rd         ( tx_data               ),  // read data
        .fifo_emp   ( tx_fifo_emp           )   // fifo empty
    );
    // creating one rx_fifo
    fifo
    #(
        .depth      ( 8                     ),
        .data_w     ( 8                     )
    )
    rx_fifo
    (
        // clock and reset
        .clk        ( clk                   ),  // clock
        .rstn       ( rstn                  ),  // reset
        // fifo write
        .fifo_lvl   ( cr_out.rx_fifo_lvl    ),  // fifo full level trigger
        .we         ( rx_valid              ),  // write enable
        .wd         ( rx_data               ),  // write data
        .fifo_full  ( cr_out.rx_full        ),  // fifo full
        // fifo read
        .re         ( uart_rx_re            ),  // read enable
        .rd         ( rx_fifo_data          ),  // read data
        .fifo_emp   (                       )   // fifo empty
    );
    // creating one uart_transmitter_0
    uart_transmitter
    uart_transmitter_0
    (
        // reset and clock
        .clk        ( clk                   ),  // clk
        .rstn       ( rstn                  ),  // reset
        // controller side interface
        .tr_en      ( cr_out.tr_en          ),  // transmitter enable
        .dfv        ( dfr                   ),  // divide frequency value
        .tx_data    ( tx_data               ),  // data for transfer
        .req        ( tx_req                ),  // request signal
        .next_tx    ( next_tx               ),  // next tx request for fifo
        // uart tx side
        .uart_tx    ( uart_tx               )   // UART tx wire
    );
    // creating one uart_receiver_0
    uart_receiver
    uart_receiver_0
    (
        // reset and clock
        .clk        ( clk                   ),  // clk
        .rstn       ( rstn                  ),  // reset
        // controller side interface
        .rec_en     ( cr_out.rec_en         ),  // receiver enable
        .dfv        ( dfr                   ),  // divide frequency value
        .rx_data    ( rx_data               ),  // received data
        .rx_valid   ( rx_valid              ),  // receiver data valid
        // uart rx side
        .uart_rx    ( uart_rx               )   // UART rx wire
    );

    function automatic logic [0 : 0] we_find(logic [0 : 0] we_in, logic [31 : 0] addr_in, logic [31 : 0] addr_v);
        return we_in && ( addr_in == addr_v );
    endfunction : we_find

endmodule : uart
