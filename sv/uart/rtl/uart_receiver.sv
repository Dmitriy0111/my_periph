/* 
*  File            :   uart_receiver.vhd
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.05
*  Language        :   SystemVerilog
*  Description     :   This uart receiver module
*  Copyright(c)    :   2019 Vlasov D.V.
*/ 

module uart_receiver
(
    // reset and clock
    input   logic   [0  : 0]    clk,            // clk
    input   logic   [0  : 0]    rstn,           // reset
    // controller side interface
    input   logic   [0  : 0]    rec_en,         // receiver enable
    input   logic   [15 : 0]    dfv,            // divide frequency value
    output  logic   [7  : 0]    rx_data,        // received data
    output  logic   [0  : 0]    rx_valid,       // receiver data valid
    // uart rx side
    input   logic   [0  : 0]    uart_rx         // UART rx wire
);

    logic   [7  : 0]    int_reg;        // internal register
    logic   [3  : 0]    bit_counter;    // bit counter for internal register
    logic   [15 : 0]    counter;        // counter for baudrate
    logic   [0  : 0]    idle2rec;       // idle to receive
    logic   [0  : 0]    rec2idle;       // receive to wait

    enum
    logic   [1  : 0]    { IDLE_s , RECEIVE_s } state, next_state;

    assign idle2rec  = uart_rx == '0;
    assign rec2idle  = bit_counter == 4'h9;
    
    assign rx_data = int_reg;
    assign rx_valid = rec2idle && ( state == RECEIVE_s );

    // Change FSM state
    always_ff @(posedge clk)
        if( ! rstn )
            state <= IDLE_s;
        else
            state <= rec_en ? next_state : IDLE_s;
    // Finding next state for FSM
    always_comb
    begin
        next_state = state;
        case( state )
            IDLE_s      : next_state = idle2rec ? RECEIVE_s : state;
            RECEIVE_s   : next_state = rec2idle ? IDLE_s    : state;
            default     : next_state = IDLE_s;
        endcase
    end
    // Other FSM sequence logic
    always_ff @(posedge clk)
        if( ! rstn )
        begin
            counter  <= '0;
            int_reg  <= '0;
            bit_counter <= '0;
        end
        else if( ! rec_en )
        begin
            counter <= '0;
            bit_counter <= '0;
            int_reg <= '0;
        end
        else
            case( state )
                IDLE_s      :
                begin
                    bit_counter <= '0;
                    counter <= '0;
                end
                RECEIVE_s   :
                begin
                    counter <= counter + 1'b1;
                    if( counter >= dfv )
                    begin
                        counter <= '0;
                        bit_counter <= bit_counter + 1'b1;
                    end
                    if( counter == dfv >> 2 )
                        int_reg <= { uart_rx , int_reg[7 : 1] };
                end
                default     : ;
            endcase

endmodule : uart_receiver
