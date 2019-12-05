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

    typedef struct packed{
        logic   [1 : 0]     rx_fifo_lvl;
        logic   [1 : 0]     tx_fifo_lvl;
        logic   [0 : 0]     rx_full;
        logic   [0 : 0]     tx_full;
        logic   [0 : 0]     rec_en;
        logic   [0 : 0]     tr_en;
    } uart_cr;

    parameter           T = 10,
                        start_del = 200,
                        rst_delay = 7,
                        repeat_n = 200;

    // reset and clock
    logic   [0  : 0]    clk;        // clk
    logic   [0  : 0]    rstn;       // reset
    // simple interface
    logic   [3  : 0]    addr;       // address
    logic   [0  : 0]    re;
    logic   [0  : 0]    we;         // write enable
    logic   [31 : 0]    wd;         // write data
    logic   [31 : 0]    rd;         // read data
    // uart side
    logic   [0  : 0]    uart_tx;    // UART tx wire
    logic   [0  : 0]    uart_rx;    // UART rx wire

    uart_cr             uart_cr_0;

    string  uart_msg = "Hello World!\n";

    assign uart_rx = uart_tx;

    uart_top_si
    dut
    (
        // reset and clock
        .clk        ( clk       ),  // clk
        .rstn       ( rstn      ),  // reset
        // simple interface
        .addr       ( addr      ),  // address
        .re         ( re        ),  // read enable
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
        re = '1;
        @(posedge clk);
        re = '0;
        r_data = rd;
    endtask : read_reg

    task send_msg(string msg);
        bit   [7 : 0] ctrl_reg;
        logic [7 : 0] rec_reg;
        for(int i = 0 ; i < msg.len ; i++)
        begin
            $display("Send data = 0x%h (%c)",msg[i],msg[i]);
            write_reg(4'h4,msg[i]);
            for(;;)
            begin
                read_reg(4'h0,ctrl_reg);
                if( ctrl_reg & 8'h08 )
                begin
                    read_reg(4'h4,rec_reg);
                    $display("Received data = 0x%h (%c)",rec_reg,rec_reg);
                end
                if( !(ctrl_reg & 8'h04) )
                    break;
            end
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
        re = '0; 
        wd = '0; 
        uart_cr_0.tr_en = '1;
        uart_cr_0.rec_en = '1;
        uart_cr_0.rx_fifo_lvl = 2'b10;
        uart_cr_0.tx_fifo_lvl = 2'b10;
        uart_cr_0.rx_full = '0;
        uart_cr_0.tx_full = '0;
        write_reg(4'h0,uart_cr_0);
        write_reg(4'h8,16'h200);
        send_msg(uart_msg);
        $stop;
    end

endmodule : uart_top_si_tb
