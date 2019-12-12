/* 
*  File            :   uart.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.04.24
*  Language        :   SystemVerilog
*  Description     :   This is uart module with simple interface
*  Copyright(c)    :   2019 Vlasov D.V.
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
    // uart side
    output  logic   [0  : 0]    uart_tx,    // UART tx wire
    input   logic   [0  : 0]    uart_rx     // UART rx wire
);

    // write/read enable signals 
    logic   [0  : 0]    uart_cr_we;     // UART control register write enable
    logic   [0  : 0]    uart_tx_we;     // UART transmitter register write enable
    logic   [0  : 0]    uart_rx_re;     // UART receiver register read enable
    logic   [0  : 0]    uart_dv_we;     // UART divider register write enable
    logic   [0  : 0]    irq_m_we;       // UART interrupt mask write enable
    logic   [0  : 0]    irq_v_we;       // UART interrupt vector write enable
    logic   [7  : 0]    irq_v_we_f;     // UART interrupt vector write enable final
    // uart transmitter other signals
    logic   [0  : 0]    tx_fifo_emp;    // transmitter fifo empty
    logic   [0  : 0]    tx_req;         // request transmit
    logic   [0  : 0]    next_tx;        // next transmittion
    // transmitter/receiver enable signals
    logic   [0  : 0]    tr_en;          // transmitter enable
    logic   [0  : 0]    rec_en;         // receiver enable
    logic   [0  : 0]    tx_full;        // transmitter busy
    logic   [0  : 0]    rx_fifo_full;   // receiver fifo full
    logic   [0  : 0]    rx_valid;       // receive valid
    //
    logic   [15 : 0]    udvr;           // "dividing frequency"
    logic   [7  : 0]    tx_data;        // transmitted data from fifo
    logic   [1  : 0]    tx_fifo_lvl;    // transmitter fifo level
    logic   [1  : 0]    rx_fifo_lvl;    // transmitter fifo level
    logic   [7  : 0]    rx_data;        // received data
    logic   [7  : 0]    irq_m;          // interrupt mask
    logic   [7  : 0]    rx_fifo_data;   // received data from fifo

    irq_v               irq_v_in;
    irq_v               irq_v_out;

    // assign write enable signals
    assign uart_cr_we = we_find( we, addr, UART_CR    );
    assign uart_tx_we = we_find( we, addr, UART_TX_RX );
    assign uart_rx_re = we_find( re, addr, UART_TX_RX );
    assign uart_dv_we = we_find( we, addr, UART_DR    );
    assign irq_m_we   = we_find( we, addr, UART_IRQ_M );
    assign irq_v_we   = we_find( we, addr, UART_IRQ_V );

    assign tx_req = ! tx_fifo_emp;
    assign irq = |irq_v_out;
    assign irq_v_in.un = '0;
    assign irq_v_out.un = '0;
    assign irq_v_we_f[7 : 4] = '0;
    assign irq_v_we_f[3] = irq_v_we || ( rx_fifo_full && irq_m[3] );
    assign irq_v_we_f[2] = irq_v_we || ( tx_fifo_emp  && irq_m[2] );
    assign irq_v_we_f[1] = irq_v_we || ( rx_valid     && irq_m[1] );
    assign irq_v_we_f[0] = irq_v_we || ( next_tx      && irq_m[0] );
    assign irq_v_in.rff = ( rx_fifo_full && irq_m[3] ) ? '1 : wd[3];
    assign irq_v_in.tfe = ( tx_fifo_emp  && irq_m[2] ) ? '1 : wd[2];
    assign irq_v_in.rc  = ( rx_valid     && irq_m[1] ) ? '1 : wd[1];
    assign irq_v_in.tc  = ( next_tx      && irq_m[0] ) ? '1 : wd[0];

    // mux for routing one register value
    always_comb
    begin
        rd <= { '0 , rx_fifo_lvl, tx_fifo_lvl, rx_fifo_full, tx_full, tr_en, rec_en };
        case( addr )
            UART_CR     : rd <= { '0 , rx_fifo_lvl, tx_fifo_lvl, rx_fifo_full, tx_full, tr_en, rec_en };
            UART_TX_RX  : rd <= { '0 , rx_fifo_data };
            UART_DR     : rd <= { '0 , udvr };
            UART_IRQ_M  : rd <= { '0 , irq_m };
            UART_IRQ_V  : rd <= { '0 , irq_v_out };
        endcase
    end
    // creating control and data registers
    reg_we  #(  1 )     tr_en_reg       ( clk , rstn , uart_cr_we    , wd[0]        , tr_en          );
    reg_we  #(  1 )     rec_en_reg      ( clk , rstn , uart_cr_we    , wd[1]        , rec_en         );
    reg_we  #(  2 )     fifo_tx_lvl_reg ( clk , rstn , uart_cr_we    , wd[5  : 4]   , tx_fifo_lvl    );
    reg_we  #(  2 )     fifo_rx_lvl_reg ( clk , rstn , uart_cr_we    , wd[7  : 6]   , rx_fifo_lvl    );
    reg_we  #( 16 )     div_reg         ( clk , rstn , uart_dv_we    , wd[15 : 0]   , udvr           );
    reg_we  #(  8 )     irq_m_reg       ( clk , rstn , irq_m_we      , wd[7  : 0]   , irq_m          );
    reg_we  #(  1 )     irq_rff_reg     ( clk , rstn , irq_v_we_f[3] , irq_v_in.rff , irq_v_out.rff  );
    reg_we  #(  1 )     irq_tfe_reg     ( clk , rstn , irq_v_we_f[2] , irq_v_in.tfe , irq_v_out.tfe  );
    reg_we  #(  1 )     irq_rc_reg      ( clk , rstn , irq_v_we_f[1] , irq_v_in.rc  , irq_v_out.rc   );
    reg_we  #(  1 )     irq_tc_reg      ( clk , rstn , irq_v_we_f[0] , irq_v_in.tc  , irq_v_out.tc   );
    // creating one tx_fifo
    fifo
    #(
        .depth      ( 8             ),
        .data_w     ( 8             )
    )
    tx_fifo
    (
        // clock and reset
        .clk        ( clk           ),  // clock
        .rstn       ( rstn          ),  // reset
        // fifo write
        .fifo_lvl   ( tx_fifo_lvl   ),  // fifo full level trigger
        .we         ( uart_tx_we    ),  // write enable
        .wd         ( wd            ),  // write data
        .fifo_full  ( tx_full       ),  // fifo full
        // fifo read
        .re         ( next_tx       ),  // read enable
        .rd         ( tx_data       ),  // read data
        .fifo_emp   ( tx_fifo_emp   )   // fifo empty
    );
    // creating one rx_fifo
    fifo
    #(
        .depth      ( 8             ),
        .data_w     ( 8             )
    )
    rx_fifo
    (
        // clock and reset
        .clk        ( clk           ),  // clock
        .rstn       ( rstn          ),  // reset
        // fifo write
        .fifo_lvl   ( rx_fifo_lvl   ),  // fifo full level trigger
        .we         ( rx_valid      ),  // write enable
        .wd         ( rx_data       ),  // write data
        .fifo_full  ( rx_fifo_full  ),  // fifo full
        // fifo read
        .re         ( uart_rx_re    ),  // read enable
        .rd         ( rx_fifo_data  ),  // read data
        .fifo_emp   (               )   // fifo empty
    );
    // creating one uart_transmitter_0
    uart_transmitter
    uart_transmitter_0
    (
        // reset and clock
        .clk        ( clk           ),  // clk
        .rstn       ( rstn          ),  // reset
        // controller side interface
        .tr_en      ( tr_en         ),  // transmitter enable
        .comp       ( udvr          ),  // compare input for setting baudrate
        .tx_data    ( tx_data       ),  // data for transfer
        .req        ( tx_req        ),  // request signal
        .next_tx    ( next_tx       ),  // next tx request for fifo
        // uart tx side
        .uart_tx    ( uart_tx       )   // UART tx wire
    );
    // creating one uart_receiver_0
    uart_receiver
    uart_receiver_0
    (
        // reset and clock
        .clk        ( clk           ),  // clk
        .rstn       ( rstn          ),  // reset
        // controller side interface
        .rec_en     ( rec_en        ),  // receiver enable
        .comp       ( udvr          ),  // compare input for setting baudrate
        .rx_data    ( rx_data       ),  // received data
        .rx_valid   ( rx_valid      ),  // receiver data valid
        // uart rx side
        .uart_rx    ( uart_rx       )   // UART rx wire
    );

    function automatic logic [0 : 0] we_find(logic [0 : 0] we_in, logic [31 : 0] addr_in, logic [31 : 0] addr_v);
        return we_in && ( addr_in == addr_v );
    endfunction : we_find

endmodule : uart
