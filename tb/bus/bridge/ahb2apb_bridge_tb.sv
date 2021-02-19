/* 
*  File            :   ahb2apb_bridge_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.23
*  Language        :   SystemVerilog
*  Description     :   This ahb to apb bridge testbench
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

module ahb2apb_bridge_tb();

    timeprecision                       1ns;
    timeunit                            1ns;

    parameter               a_w = 20,
                            cdc_use = 0;

    parameter               T = 10,
                            Tp = (cdc_use == 1) ? T*7 : T,
                            start_del = 200,
                            rst_delay = 7,
                            repeat_n = 2000;

    // AHB clock and reset
    logic   [0     : 0]     hclk;       // ahb clk
    logic   [0     : 0]     hresetn;    // ahb resetn
    // AHB - Slave side
    logic   [31    : 0]     haddr_s;    // ahb slave address
    logic   [31    : 0]     hrdata_s;   // ahb slave read data
    logic   [31    : 0]     hwdata_s;   // ahb slave write data
    logic   [0     : 0]     hwrite_s;   // ahb slave write signal
    logic   [1     : 0]     htrans_s;   // ahb slave trans
    logic   [2     : 0]     hsize_s;    // ahb slave size
    logic   [2     : 0]     hburst_s;   // ahb slave burst
    logic   [1     : 0]     hresp_s;    // ahb slave response
    logic   [0     : 0]     hready_s;   // ahb slave ready
    logic   [0     : 0]     hsel_s;     // ahb slave select
    // APB clock and reset
    logic   [0     : 0]     pclk;       // apb clk
    logic   [0     : 0]     presetn;    // apb resetn
    // APB - Master side
    logic   [a_w-1 : 0]     paddr;      // apb master address
    logic   [31    : 0]     pwdata;     // apb master write data
    logic   [31    : 0]     prdata;     // apb master read data
    logic   [0     : 0]     pwrite;     // apb master write signal
    logic   [0     : 0]     penable;    // apb master enable
    logic   [0     : 0]     pready;     // apb master ready
    logic   [0     : 0]     psel;       // apb master select

    logic   [31    : 0]     slv [2**a_w-1];

    integer                 addr_q  [$];
    logic   [31    : 0]     data_wq [integer];
    logic   [31    : 0]     data_rq [integer];

    ahb2apb_bridge
    #(
        .a_w        ( a_w       ),
        .cdc_use    ( cdc_use   )
    )
    dut
    (
        // AHB clock and reset
        .hclk       ( hclk      ),      // ahb clk
        .hresetn    ( hresetn   ),      // ahb resetn
        // AHB - Slave side
        .haddr_s    ( haddr_s   ),      // ahb slave address
        .hrdata_s   ( hrdata_s  ),      // ahb slave read data
        .hwdata_s   ( hwdata_s  ),      // ahb slave write data
        .hwrite_s   ( hwrite_s  ),      // ahb slave write signal
        .htrans_s   ( htrans_s  ),      // ahb slave trans
        .hsize_s    ( hsize_s   ),      // ahb slave size
        .hburst_s   ( hburst_s  ),      // ahb slave burst
        .hresp_s    ( hresp_s   ),      // ahb slave response
        .hready_s   ( hready_s  ),      // ahb slave ready
        .hsel_s     ( hsel_s    ),      // ahb slave select
        // APB clock and reset
        .pclk       ( pclk      ),      // apb clk
        .presetn    ( presetn   ),      // apb resetn
        // APB - Master side
        .paddr      ( paddr     ),      // apb master address
        .pwdata     ( pwdata    ),      // apb master write data
        .prdata     ( prdata    ),      // apb master read data
        .pwrite     ( pwrite    ),      // apb master write signal
        .penable    ( penable   ),      // apb master enable
        .pready     ( pready    ),      // apb master ready
        .psel       ( psel      )       // apb master select
    );

    task write_data(logic [31 : 0] wr_addr, logic [31 : 0] wr_data);
        logic [31 : 0] wr_data_h;
        logic [31 : 0] wr_addr_h;
        haddr_s = wr_addr;
        hwrite_s = '1;
        htrans_s = '1;
        hsel_s = '1;
        @(posedge hclk);
        htrans_s = '0;
        wr_data_h = wr_data;
        wr_addr_h = wr_addr;
        fork
            begin
                data_wq[wr_addr_h] = wr_data_h;
                hwdata_s = wr_data_h;
            end
        join_none
        wait(hready_s == '1);
        @(posedge hclk);
    endtask : write_data

    task read_data(logic [31 : 0] rd_addr);
        logic [31 : 0] rd_addr_h;
        haddr_s = rd_addr;
        hwrite_s = '0;
        htrans_s = '1;
        hsel_s = '1;
        @(posedge hclk);
        htrans_s = '0;
        rd_addr_h = rd_addr;
        wait(hready_s == '1);
        @(posedge hclk);
        fork
            begin
                @(posedge hclk);
                data_rq[rd_addr_h] = hrdata_s;
                $display("rd_addr = 0x%h, rd_data = 0x%h", rd_addr_h, hrdata_s );
            end
        join_none
    endtask : read_data

    // AHB
    initial
    begin
        # start_del;
        hclk = '0;
        forever
            #(T/2) hclk <= !hclk;
    end

    initial
    begin
        # start_del;
        hresetn = '0;
        repeat(rst_delay) @(posedge hclk);
        hresetn = '1;
    end

    initial
    begin
        # start_del;
        @(posedge hresetn);
        haddr_s = '0;
        hwdata_s = '0;
        hwrite_s = '0;
        htrans_s = '0;
        hsize_s = '0;
        hburst_s = '0;
        repeat(repeat_n) 
        begin
            int wr_addr;
            int wr_data;
            wr_addr = $urandom_range(0,2**a_w-1);
            wr_addr = wr_addr & (~3);
            wr_data = $random();
            addr_q.push_back(wr_addr);
            $display("wr_addr = 0x%h, wr_data = 0x%h", wr_addr, wr_data);
            write_data(wr_addr,wr_data);
        end
        for( int i = 0 ; i < addr_q.size ; i++ )
            read_data(addr_q[i]);
        repeat(20) @(posedge hclk);
        for(;addr_q.size != 0;)
        begin
            integer addr;
            addr = addr_q.pop_front();
            if( data_rq[addr] != data_wq[addr] )
                $display("Error wr_data = 0x%h, rd_data = 0x%h", data_wq[addr], data_rq[addr] );
        end
        $stop;
    end

    // APB
    initial
    begin
        # start_del;
        pclk = '0;
        forever
            #(Tp/2) pclk <= !pclk;
    end

    initial
    begin
        # start_del;
        presetn = '0;
        repeat(rst_delay) @(posedge pclk);
        presetn = '1;
    end

    initial
    begin
        # start_del;
        pready = '0;
        forever
        begin
            @(posedge pclk);
            if( pwrite && psel )
            begin
                @(posedge pclk);
                pready = '1;
                @(posedge pclk);
                pready = '0;
                if( pwrite && penable && psel )
                begin
                    slv[paddr] = pwdata;
                    $display("slv[0x%8h] = 0x%8h", paddr, slv[paddr]);
                end
            end
            else if( ( ! pwrite ) && psel )
            begin
                @(posedge pclk);
                pready = '1;
                prdata = slv[paddr];
                @(posedge pclk);
                pready = '0;
            end
        end
    end

endmodule : ahb2apb_bridge_tb
