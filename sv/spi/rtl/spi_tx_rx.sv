/* 
*  File            :   spi_tx_rx.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.13
*  Language        :   SystemVerilog
*  Description     :   This is spi transmitter receiver module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module spi_tx_rx
#(
    parameter                       cs_w = 8
)(
    // reset and clock
    input   logic   [0      : 0]    clk,        // clk
    input   logic   [0      : 0]    rstn,       // reset
    // control and data
    input   logic   [cs_w-1 : 0]    cs_v,       // cs values
    input   logic   [7      : 0]    dfv,        // dividing frequency value
    input   logic   [7      : 0]    tx_data,    // data for transmitting
    output  logic   [7      : 0]    rx_data,    // received data
    input   logic   [0      : 0]    cpol,       // cpol value
    input   logic   [0      : 0]    cpha,       // cpha value
    input   logic   [0      : 0]    msb_lsb,    // msb/lsb first
    input   logic   [0      : 0]    tx_req,     // transmit request
    output  logic   [0      : 0]    tx_req_ack, // transmit request acknowledge
    // SPI side
    output  logic   [0      : 0]    spi_mosi,   // SPI mosi wire
    input   logic   [0      : 0]    spi_miso,   // SPI miso wire
    output  logic   [0      : 0]    spi_sck,    // SPI sck wire
    output  logic   [cs_w-1 : 0]    spi_cs      // SPI cs wire
);
    
    logic   [7  : 0]    int_reg;
    logic   [7  : 0]    counter;
    logic   [3  : 0]    bit_c;
    logic   [0  : 0]    sck_int;

    logic   [0  : 0]    idle2tr;
    logic   [0  : 0]    tr2idle;

    enum
    logic   [0  : 0]    { IDLE_s, TRANSMIT_s } state, next_state;

    assign spi_cs = ~ cs_v;
    assign rx_data = int_reg;
    assign spi_sck = sck_int ^ cpol;

    assign idle2tr = tx_req && ! tx_req_ack;
    assign tr2idle = ( counter >= dfv ) && ( bit_c == 15 );

    // Change FSM state
    always_ff @(posedge clk)
        if( !rstn )
            state <= IDLE_s;
        else
            state <= next_state;
    // Finding next state for FSM
    always_comb
    begin
        next_state = state;
        case( state )
            IDLE_s      : next_state = idle2tr ? TRANSMIT_s : state;
            TRANSMIT_s  : next_state = tr2idle ? IDLE_s     : state;
            default     : next_state = IDLE_s;
        endcase
    end
    // Other FSM sequence logic
    always_ff @(posedge clk)
        if( ! rstn )
        begin
            bit_c <= '0;
            counter <= '0;
            tx_req_ack <= '0;
            sck_int <= '0;
        end
        else
            case( state )
                IDLE_s  : 
                begin
                    tx_req_ack <= '0;
                    sck_int <= '0;
                    if( idle2tr )
                    begin
                        bit_c <= '0;
                        counter <= '0;
                        int_reg <= tx_data;
                    end
                end
                TRANSMIT_s  : 
                begin
                    counter <= counter + 1'b1;
                    if( ( ~ cpha ) && ( counter == '0 ) )
                    begin
                        if( ~ bit_c[0] )
                            spi_mosi <= msb_lsb ? int_reg[7] : int_reg[0];
                        else
                            int_reg <= msb_lsb ? { int_reg[6 : 0] , spi_miso } : { spi_miso , int_reg[7 : 1] };
                    end
                    else if( cpha && ( counter >= dfv ) )
                    begin
                        if( ~ bit_c[0] )
                            spi_mosi <= msb_lsb ? int_reg[7] : int_reg[0];
                        else
                            int_reg <= msb_lsb ? { int_reg[6 : 0] , spi_miso } : { spi_miso , int_reg[7 : 1] };
                    end
                    if( counter >= dfv )
                    begin
                        counter <= '0;
                        bit_c <= bit_c + 1'b1;
                        if( tr2idle )
                        begin
                            bit_c <= '0;
                            tx_req_ack <= '1;
                        end
                        sck_int <= ~ sck_int;
                    end
                end
            endcase

endmodule : spi_tx_rx
