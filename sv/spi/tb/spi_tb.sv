/* 
*  File            :   spi_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.10
*  Language        :   SystemVerilog
*  Description     :   This is testbench for spi module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "../rtl/spi.svh"

module spi_tb();

    timeprecision           1ns;
    timeunit                1ns;

    parameter               T = 10,
                            start_del = 200,
                            rst_delay = 7,
                            repeat_n = 200;

    parameter               cs_w = 8;
    // reset and clock
    logic   [0      : 0]    clk;
    logic   [0      : 0]    rstn;
    // simple interface
    logic   [4      : 0]    addr;
    logic   [0      : 0]    re;
    logic   [0      : 0]    we;
    logic   [31     : 0]    wd;
    logic   [31     : 0]    rd;
    // IRQ
    logic   [0      : 0]    irq;
    // spi side
    logic   [0      : 0]    spi_mosi;
    logic   [0      : 0]    spi_miso;
    logic   [0      : 0]    spi_sck;
    logic   [cs_w-1 : 0]    spi_cs;

    string                  uart_msg = "Hello World!\n";

    spi_cr_v                spi_cr_vec;
    spi_sr_v                spi_sr_ver;
    spi_irq_v               spi_irq_vec;
    integer                 dfr;

    assign spi_miso = spi_mosi;

    spi
    #(
        .cs_w       ( cs_w      )
    )
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
        // IRQ
        .irq        ( irq       ),  // interrupt request
        // SPI side
        .spi_mosi   ( spi_mosi  ),  // SPI mosi wire
        .spi_miso   ( spi_miso  ),  // SPI miso wire
        .spi_sck    ( spi_sck   ),  // SPI sck wire
        .spi_cs     ( spi_cs    )   // SPI cs wire
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
        logic [7 : 0] rec_reg;
        for(int i = 0 ; i < msg.len ; i++)
        begin
            $display("Send data = 0x%h (%c)",msg[i],msg[i]);
            write_reg(SPI_DR,msg[i]);
            for(;;)
            begin
                read_reg(SPI_SR,spi_sr_ver);
                if( irq )
                begin
                    repeat(1 << spi_cr_vec.rx_fifo_lvl)
                    begin
                        read_reg(SPI_DR,rec_reg);
                        $display("Received data = 0x%h (%c)",rec_reg,rec_reg);
                    end
                    write_reg(SPI_IRQ_V,0);
                end
                if( !(spi_sr_ver.tx_fifo_full) )
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
        spi_cr_vec = '0;
        spi_cr_vec.rx_fifo_lvl = 2'b01;
        spi_cr_vec.tx_fifo_lvl = 2'b01;
        spi_cr_vec.msb_lsb = '0;
        spi_cr_vec.cpol = '0;
        spi_cr_vec.cpha = '0;
        spi_irq_vec = '0;
        spi_irq_vec.rx_fifo_full = '1;
        dfr = 200;
        write_reg( SPI_CR    , spi_cr_vec  );
        write_reg( SPI_DFR   , dfr         );
        write_reg( SPI_CS_V  , 8'h55       );
        write_reg( SPI_IRQ_M , spi_irq_vec );
        send_msg(uart_msg);
        $stop;
    end

endmodule : spi_tb
