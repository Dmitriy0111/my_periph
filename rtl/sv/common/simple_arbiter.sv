/*
*  File            :   simple_arbiter.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.19
*  Language        :   SystemVerilog
*  Description     :   This is simple arbiter module
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

module simple_arbiter
#(
    parameter                               m_w = 2
)(
    // clock and reset
    input   logic              [0  : 0]     clk,        // clock
    input   logic              [0  : 0]     rstn,       // reset
    // bus control
    input   logic   [m_w-1 : 0]             bus_req,    // bus request
    input   logic   [m_w-1 : 0]             bus_lock,   // bus lock
    output  logic   [m_w-1 : 0]             bus_grant,  // bus grant
    // bus master
    input   logic   [m_w-1 : 0][31 : 0]     addr_m,     // address
    output  logic   [m_w-1 : 0][31 : 0]     rd_m,       // read data
    input   logic   [m_w-1 : 0][31 : 0]     wd_m,       // write data
    input   logic   [m_w-1 : 0][0  : 0]     we_m,       // write enable
    input   logic   [m_w-1 : 0][1  : 0]     size_m,     // size
    // bus slave
    output  logic              [31 : 0]     addr_f,     // address
    input   logic              [31 : 0]     rd_f,       // read data
    output  logic              [31 : 0]     wd_f,       // write data
    output  logic              [0  : 0]     we_f,       // write enable
    output  logic              [1  : 0]     size_f      // size
);

    logic   [m_w-1 : 0]     mst_en;
    logic   [m_w-1 : 0]     bus_req_pri;

    assign addr_f = addr_m[mst_en];
    assign wd_f = wd_m[mst_en];
    assign size_f = size_m[mst_en];
    assign we_f = we_m[mst_en];
    assign rd_m[0] = rd_f;
    assign rd_m[1] = rd_f;

    always_ff @(posedge clk)
    begin
        if( ! rstn )
        begin
            mst_en <= '0;
            bus_grant <= '0;
        end
        else
            if( ( bus_req[1] == '1 ) && ( bus_lock[1] == '1 ) && ( mst_en == '0 ) )
            begin
                bus_grant[0] <= '0;
                bus_grant[1] <= '1;
                mst_en <= 1;
            end
            if( ( bus_req[0] == '1 ) && ( bus_lock[1] == '0 ) )
            begin
                bus_grant[0] <= '1;
                bus_grant[1] <= '0;
                mst_en <= 0;
            end
    end

endmodule : simple_arbiter
