/* 
*  File            :   uart_transmitter.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.04.24
*  Language        :   SystemVerilog
*  Description     :   This uart transmitter module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module uart_transmitter
(
    // reset and clock
    input   logic   [0  : 0]    clk,        // clk
    input   logic   [0  : 0]    rstn,       // reset
    // controller side interface
    input   logic   [0  : 0]    tr_en,      // transmitter enable
    input   logic   [15 : 0]    comp,       // compare input for setting baudrate
    input   logic   [7  : 0]    tx_data,    // data for transfer
    input   logic   [0  : 0]    req,        // request signal
    output  logic   [0  : 0]    next_tx,    
    // uart tx side
    output  logic   [0  : 0]    uart_tx     // UART tx wire
);

    logic   [7  : 0]    int_reg;
    logic   [3  : 0]    bit_counter;
    logic   [15 : 0]    counter;

    logic   [0  : 0]    idle2start;
    logic   [0  : 0]    start2tr;
    logic   [0  : 0]    tr2stop;
    logic   [0  : 0]    stop2idle;

    enum
    logic   [1  : 0]    { IDLE_s, START_s, TRANSMIT_s, STOP_s } state, next_state;

    assign idle2start = req;
    assign start2tr   = counter >= comp;
    assign tr2stop    = bit_counter == 4'h8;
    assign stop2idle  = counter >= comp;
    assign next_tx    = stop2idle && ( state == STOP_s );

    // Change FSM state
    always_ff @(posedge clk)
        if( !rstn )
            state <= IDLE_s;
        else
            state <= tr_en ? next_state : IDLE_s;
    // Finding next state for FSM
    always_comb
    begin
        next_state = state;
        case( state )
            IDLE_s      : next_state = ( idle2start ? START_s    : state );
            START_s     : next_state = ( start2tr   ? TRANSMIT_s : state );
            TRANSMIT_s  : next_state = ( tr2stop    ? STOP_s     : state );
            STOP_s      : next_state = ( stop2idle  ? IDLE_s     : state );
            default     : next_state = IDLE_s;
        endcase
    end
    // Other FSM sequence logic
    always_ff @(posedge clk)
        if( ! rstn )
        begin
            bit_counter <= '0;
            int_reg <= '1;
            uart_tx <= '1;
            counter <= '0;
        end
        else if( ! tr_en )
        begin
            bit_counter <= '0;
            int_reg <= '1;
            uart_tx <= '1;
            counter <= '0;
        end
        else
            case( state )
                IDLE_s  : 
                begin
                    uart_tx <= '1;
                    if( idle2start )
                    begin
                        bit_counter <= '0;
                        counter <= '0;
                        int_reg <= tx_data;
                    end
                end
                START_s : 
                begin
                    uart_tx <= '0;
                    counter <= counter + 1'b1;
                    if( counter >= comp )
                        counter <= '0;
                end
                TRANSMIT_s  : 
                begin
                    uart_tx <= int_reg[bit_counter];
                    counter <= counter + 1'b1;
                    if( counter >= comp )
                    begin
                        counter <= '0;
                        bit_counter <= bit_counter + 1'b1;
                    end
                    if( bit_counter == 4'h8 )
                    begin
                        bit_counter <= '0;
                        uart_tx <= '1;
                    end
                end
                STOP_s  : 
                begin
                    counter <= counter + 1'b1;
                    if( counter >= comp )
                        counter <= '0;
                end
            endcase

endmodule : uart_transmitter
