/* 
*  File            :   uart_top_si_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.04.24
*  Language        :   SystemVerilog
*  Description     :   This uart top module simple interface
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module uart_top_si_tb();

    timeprecision       1ns;
    timeunit            1ns;

    parameter           T = 10,
                        start_del = 200,
                        rst_delay = 7,
                        repeat_n = 200;

    // reset and clock
    logic   [0  : 0]    clk;        // clk
    logic   [0  : 0]    rstn;       // reset
    // simple interface
    logic   [3  : 0]    addr;       // address
    logic   [0  : 0]    we;         // write enable
    logic   [31 : 0]    wd;         // write data
    logic   [31 : 0]    rd;         // read data
    // uart side
    logic   [0  : 0]    uart_tx;    // UART tx wire
    logic   [0  : 0]    uart_rx;    // UART rx wire

    string  uart_msg = "Hello World!\n";

    uart_top_si
    dut
    (
        // reset and clock
        .clk        ( clk       ),  // clk
        .rstn       ( rstn      ),  // reset
        // simple interface
        .addr       ( addr      ),  // address
        .we         ( we        ),  // write enable
        .wd         ( wd        ),  // write data
        .rd         ( rd        ),  // read data
        // uart side
        .uart_tx    ( uart_tx   ),  // UART tx wire
        .uart_rx    ( uart_rx   )   // UART rx wire
    );

    task write_reg(integer w_addr, integer w_data);
        addr = w_addr;
        wd = w_data;
        we = '1;
        @(posedge clk);
        we = '0;
    endtask : write_reg

    task read_reg(integer r_addr, output integer r_data);
        addr = r_addr;
        @(posedge clk);
        r_data = rd;
    endtask : read_reg

    task send_msg(string msg);
        bit [7 : 0] ctrl_reg;
        for(int i = 0 ; i < msg.len ; i++)
        begin
            write_reg(4'h4,msg[i]);
            do
            begin
                read_reg(4'h0,ctrl_reg);
            end
            while( ctrl_reg & 8'h04 );
        end
    endtask : send_msg

    initial
    begin
        # start_del;
        clk = '0;
        forever
            #(T/2) clk <= !clk;
    end

    initial
    begin
        # start_del;
        rstn = '0;
        repeat(rst_delay) @(posedge clk);
        rstn = '1;
    end

    initial
    begin
        # start_del;
        @(posedge rstn);
        addr = '0;
        we = '0; 
        wd = '0; 
        write_reg(4'h0,8'h3);
        write_reg(4'h8,16'h200);
        send_msg(uart_msg);
        $stop;
    end

endmodule : uart_top_si_tb
