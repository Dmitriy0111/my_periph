/* 
*  File            :   ahb2apb_bridge.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.23
*  Language        :   SystemVerilog
*  Description     :   This is AHB to APB bridge module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module ahb2apb_bridge
#(
    parameter                       a_w = 8,
                                    cdc_use = 1
)(
    // AHB clock and reset
    input   logic   [0     : 0]     hclk,       // ahb clk
    input   logic   [0     : 0]     hresetn,    // ahb resetn
    // AHB - Slave side
    input   logic   [31    : 0]     haddr_s,    // ahb slave address
    output  logic   [31    : 0]     hrdata_s,   // ahb slave read data
    input   logic   [31    : 0]     hwdata_s,   // ahb slave write data
    input   logic   [0     : 0]     hwrite_s,   // ahb slave write signal
    input   logic   [1     : 0]     htrans_s,   // ahb slave trans
    input   logic   [2     : 0]     hsize_s,    // ahb slave size
    input   logic   [2     : 0]     hburst_s,   // ahb slave burst
    output  logic   [1     : 0]     hresp_s,    // ahb slave response
    output  logic   [0     : 0]     hready_s,   // ahb slave ready
    input   logic   [0     : 0]     hsel_s,     // ahb slave select
    // APB clock and reset
    input   logic   [0     : 0]     pclk,       // apb clk
    input   logic   [0     : 0]     presetn,    // apb resetn
    // APB - Master side
    output  logic   [a_w-1 : 0]     paddr,      // apb master address
    output  logic   [31    : 0]     pwdata,     // apb master write data
    input   logic   [31    : 0]     prdata,     // apb master read data
    output  logic   [0     : 0]     pwrite,     // apb master write signal
    output  logic   [0     : 0]     penable,    // apb master enable
    input   logic   [0     : 0]     pready,     // apb master ready
    output  logic   [0     : 0]     psel        // apb master select
);

    logic   [0     : 0]     trans_req;
    // AHB signals
    logic   [0     : 0]     ahb_req;
    logic   [0     : 0]     ahb_ack;
    logic   [31    : 0]     ahb_addr;
    logic   [31    : 0]     ahb_wd;
    logic   [31    : 0]     ahb_rd;
    logic   [0     : 0]     ahb_wr_rd;
    logic   [0     : 0]     h_idle2trans;
    logic   [0     : 0]     h_trans2idle;
    // APB signals
    logic   [0     : 0]     apb_req;
    logic   [0     : 0]     apb_ack;
    logic   [a_w-1 : 0]     apb_addr;
    logic   [31    : 0]     apb_wd;
    logic   [31    : 0]     apb_rd;
    logic   [0     : 0]     apb_wr_rd;
    logic   [0     : 0]     p_idle2setup;
    logic   [0     : 0]     p_setup2enable;
    logic   [0     : 0]     p_enable2idle;
    // apb fsm settings
    enum
    logic   [1     : 0]     { APB_IDLE_s , APB_SETUP_s , APB_ENABLE_s } pstate, next_pstate;
    // ahb fsm settings
    enum
    logic   [0     : 0]     { AHB_IDLE_s , AHB_TRANS_s } hstate, next_hstate;
    // CDC
    logic   [2     : 0]     req_sync;
    logic   [2     : 0]     ack_sync;

    assign trans_req = ( hsel_s && ( htrans_s != '0 ) );

    assign h_idle2trans = trans_req && (! hready_s);
    assign h_trans2idle = ahb_ack;

    assign ahb_wd    = hwdata_s;
    assign apb_wd    = ahb_wd;
    assign hrdata_s  = ahb_rd;
    assign apb_addr  = ahb_addr[0 +: a_w];
    assign apb_wr_rd = ahb_wr_rd;

    assign apb_req = ( cdc_use == 1 ) ? ( req_sync[2] ^ req_sync[1] ) : ahb_req;
    assign ahb_ack = ( cdc_use == 1 ) ? ( ack_sync[2] ^ ack_sync[1] ) : apb_ack;

    assign p_idle2setup   = apb_req;
    assign p_setup2enable = '1;
    assign p_enable2idle  = pready;

    assign hresp_s = '0;

    ////////////////////////////////////////////////////////////////////////////////
    //                              AHB statemachine                              //
    ////////////////////////////////////////////////////////////////////////////////

    // ahb fsm state change
    always_ff @(posedge hclk)
        if( ! hresetn )
            hstate <= AHB_IDLE_s;
        else
            hstate <= next_hstate;
    // Finding next state for FSM
    always_comb
    begin
        next_hstate = hstate;
        case( hstate )
            AHB_IDLE_s  : next_hstate = ( h_idle2trans == '1 ) ? AHB_TRANS_s : hstate;
            AHB_TRANS_s : next_hstate = ( h_trans2idle == '1 ) ? AHB_IDLE_s  : hstate;
            default     : next_hstate = AHB_IDLE_s;
        endcase
    end
    // Other FSM sequence logic
    always_ff @(posedge hclk)
        if( ! hresetn )
        begin
            ahb_addr  <= '0;
            hready_s  <= '0;
            ahb_wr_rd <= '0;
        end
        else
            case( hstate )
                AHB_IDLE_s  :
                begin
                    ahb_addr  <= haddr_s;
                    hready_s  <= '0;
                    ahb_wr_rd <= hwrite_s;
                end
                AHB_TRANS_s :
                begin
                    if( h_trans2idle )
                    begin
                        ahb_rd   <= apb_rd;
                        hready_s <= '1;
                    end
                end
                default     : ;
            endcase

    ////////////////////////////////////////////////////////////////////////////////
    //                              APB statemachine                              //
    ////////////////////////////////////////////////////////////////////////////////

    // apb fsm state change
    always_ff @(posedge pclk)
        if( ! presetn )
            pstate <= APB_IDLE_s;
        else
            pstate <= next_pstate;
    // Finding next state for FSM
    always_comb
    begin
        next_pstate = pstate;
        case( pstate )
            APB_IDLE_s      : next_pstate = ( p_idle2setup   == '1 ) ? APB_SETUP_s  : pstate;
            APB_SETUP_s     : next_pstate = ( p_setup2enable == '1 ) ? APB_ENABLE_s : pstate;
            APB_ENABLE_s    : next_pstate = ( p_enable2idle  == '1 ) ? APB_IDLE_s   : pstate;
            default         : next_pstate = APB_IDLE_s;
        endcase
    end
    // Other FSM sequence logic
    always_ff @(posedge pclk)
        if( ! presetn ) 
        begin
            psel    <= '0;
            paddr   <= '0;
            pwdata  <= '0;
            pwrite  <= '0;
            penable <= '0;
        end
        else
            case( pstate )
                APB_IDLE_s      :
                    if( p_idle2setup )
                    begin
                        psel    <= '1;
                        paddr   <= apb_addr;
                        pwrite  <= apb_wr_rd;
                        pwdata  <= apb_wd;
                        penable <= '0;
                    end
                APB_SETUP_s     :
                    penable <= '1;
                APB_ENABLE_s    :
                    if( p_enable2idle )
                    begin
                        psel    <= '0;
                        apb_rd  <= prdata;
                        penable <= '0;
                    end
                default         : ;
            endcase

    ////////////////////////////////////////////////////////////////////////////////
    //                                 AHB-APB CDC                                //
    ////////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge hclk)
    if( ! hresetn )
        ahb_req <= '0;
    else
        ahb_req <=  ( ( hstate == AHB_IDLE_s ) && h_idle2trans ) ?
                    ( ( cdc_use == 1 ) ? ~ ahb_req : '1 ) :
                    ( ( cdc_use == 1 ) ?   ahb_req : '0 );
    
    always_ff @(posedge hclk)
        if( ! hresetn )
            ack_sync <= '0;
        else
            ack_sync <= { ack_sync[1 : 0] , apb_ack };
    
    always_ff @(posedge pclk)
        if( ! presetn )
            req_sync <= '0;
        else
            req_sync <= { req_sync[1 : 0] , ahb_req };
    
    always_ff @(posedge pclk)
        if( ! presetn )
            apb_ack <= '0;
        else
            apb_ack <=  ( ( pstate == APB_ENABLE_s ) && p_enable2idle ) ?
                        ( ( cdc_use == 1 ) ? ~ apb_ack : '1 ) :
                        ( ( cdc_use == 1 ) ?   apb_ack : '0 );

endmodule : ahb2apb_bridge
