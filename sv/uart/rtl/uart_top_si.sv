/* 
*  File            :   uart_top_si.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.04.24
*  Language        :   SystemVerilog
*  Description     :   This uart top module simple interface
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`define UART_CR     4'h0
`define UART_TX_RX  4'h4
`define UART_DR     4'h8

module uart_top_si
(
    // reset and clock
    input   logic   [0  : 0]    clk,        // clk
    input   logic   [0  : 0]    rstn,       // reset
    // simple interface
    input   logic   [3  : 0]    addr,       // address
    input   logic   [0  : 0]    we,         // write enable
    input   logic   [31 : 0]    wd,         // write data
    output  logic   [31 : 0]    rd,         // read data
    // uart side
    output  logic   [0  : 0]    uart_tx,    // UART tx wire
    input   logic   [0  : 0]    uart_rx     // UART rx wire
);

    // write enable signals 
    logic   [0  : 0]    uart_cr_we;     // UART control register write enable
    logic   [0  : 0]    uart_tx_we;     // UART transmitter register write enable
    logic   [0  : 0]    uart_dv_we;     // UART divider register write enable
    // uart transmitter other signals
    logic   [0  : 0]    tx_fifo_emp;
    logic   [0  : 0]    tx_req;         // request transmit
    logic   [0  : 0]    next_tx;
    // transmitter/receiver enable signals
    logic   [0  : 0]    tx_en;          // transmitter enable
    logic   [0  : 0]    rx_en;          // receiver enable
    logic   [0  : 0]    tx_busy;        // transmitter busy
    //
    logic   [15 : 0]    udvr;           // "dividing frequency"
    logic   [7  : 0]    tx_data;
    logic   [7  : 0]    rx_data;

    // assign write enable signals
    assign uart_cr_we = we && ( addr == `UART_CR    );
    assign uart_tx_we = we && ( addr == `UART_TX_RX );
    assign uart_dv_we = we && ( addr == `UART_DR    );

    assign tx_req = ! tx_fifo_emp;
    assign rx_data = '0;

    // mux for routing one register value
    always_comb
    begin
        rd <= { '0 , tx_busy, tx_en, rx_en };
        case( addr )
            `UART_CR    : rd <= { '0 , tx_busy, tx_en, rx_en };
            `UART_TX_RX : rd <= { '0 , rx_data };
            `UART_DR    : rd <= { '0 , udvr };
        endcase
    end

    // creating control and data registers
    reg_we  #( 16 )     nf_uart_dv_reg  ( clk , rstn , uart_dv_we , wd[15 : 0] , udvr  );
    reg_we  #(  1 )     uart_tx_en_reg  ( clk , rstn , uart_cr_we , wd[0]      , tx_en );
    reg_we  #(  1 )     uart_rx_en_reg  ( clk , rstn , uart_cr_we , wd[1]      , rx_en );
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
        .fifo_lvl   ( 2'b10         ),
        .we         ( uart_tx_we    ),  // write enable
        .wd         ( wd            ),  // write data
        .fifo_full  ( tx_busy       ),  // fifo full
        // fifo read
        .re         ( next_tx       ),  // read enable
        .rd         ( tx_data       ),  // read data
        .fifo_emp   ( tx_fifo_emp   )   // fifo empty
    );
    // creating one uart_transmitter_0
    uart_transmitter
    uart_transmitter_0
    (
        // reset and clock
        .clk        ( clk           ),  // clk
        .rstn       ( rstn          ),  // reset
        // controller side interface
        .tr_en      ( tx_en         ),  // transmitter enable
        .comp       ( udvr          ),  // compare input for setting baudrate
        .tx_data    ( tx_data       ),  // data for transfer
        .req        ( tx_req        ),  // request signal
        .busy_tx    (               ),  // module in busy
        .next_tx    ( next_tx       ),  // next tx request for fifo
        // uart tx side
        .uart_tx    ( uart_tx       )   // UART tx wire
    );

endmodule : uart_top_si
