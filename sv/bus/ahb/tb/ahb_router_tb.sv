/* 
*  File            :   ahb_router_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.06
*  Language        :   SystemVerilog
*  Description     :   This gpio testbench
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module ahb_router_tb();

    timeprecision                   1ns;
    timeunit                        1ns;

    parameter                       T = 10,
                                    start_del = 200,
                                    rst_delay = 7,
                                    repeat_n = 200;

    parameter                       slv_c = 4;

    // clock and reset
    logic                [0  : 0]   hclk;       // ahb clock
    logic                [0  : 0]   hresetn;    // ahb reset
    // Master side
    logic   [slv_c-1 : 0][31 : 0]   haddr_am;   // ahb master address mask
    logic                [31 : 0]   haddr;      // ahb master address
    logic                [31 : 0]   hrdata;     // ahb master read data
    logic                [31 : 0]   hwdata;     // ahb master write data
    logic                [0  : 0]   hwrite;     // ahb master write signal
    logic                [1  : 0]   htrans;     // ahb master transfer control signal
    logic                [2  : 0]   hsize;      // ahb master size signal
    logic                [2  : 0]   hburst;     // ahb master burst signal
    logic                [1  : 0]   hresp;      // ahb master response signal
    logic                [0  : 0]   hready;     // ahb master ready signal
    // Slaves side
    logic   [slv_c-1 : 0][31 : 0]   haddr_s;    // ahb slave address
    logic   [slv_c-1 : 0][31 : 0]   hrdata_s;   // ahb slave read data
    logic   [slv_c-1 : 0][31 : 0]   hwdata_s;   // ahb slave write data
    logic   [slv_c-1 : 0][0  : 0]   hwrite_s;   // ahb slave write signal
    logic   [slv_c-1 : 0][1  : 0]   htrans_s;   // ahb slave transfer control signal
    logic   [slv_c-1 : 0][2  : 0]   hsize_s;    // ahb slave size signal
    logic   [slv_c-1 : 0][2  : 0]   hburst_s;   // ahb slave burst signal
    logic   [slv_c-1 : 0][1  : 0]   hresp_s;    // ahb slave response signal
    logic   [slv_c-1 : 0][0  : 0]   hready_s;   // ahb slave ready signal
    logic   [slv_c-1 : 0][0  : 0]   hsel_s;     // ahb slave select signal

    logic   [31 : 0]                slv     [slv_c][65536];

    bit     [slv_c-1 : 0][31 : 0]   slv_m;

    integer                         addr_q  [$];
    integer                         data_wq [$];
    integer                         data_rq [$];

    assign haddr_am =   
                        { 
                            { 32'h0003_XXXX },
                            { 32'h0002_XXXX },
                            { 32'h0001_XXXX },
                            { 32'h0000_XXXX }
                        };

    assign slv_m =      
                        { 
                            { 32'h0000_FFFF },
                            { 32'h0000_FFFF },
                            { 32'h0000_FFFF },
                            { 32'h0000_FFFF }
                        };

    ahb_router
    #(
        .slv_c      ( slv_c     )
    )
    dut
    (
        // clock and reset
        .hclk       ( hclk      ),  // ahb clock
        .hresetn    ( hresetn   ),  // ahb reset
        // Master side
        .haddr_am   ( haddr_am  ),  // ahb master address mask
        .haddr      ( haddr     ),  // ahb master address
        .hrdata     ( hrdata    ),  // ahb master read data
        .hwdata     ( hwdata    ),  // ahb master write data
        .hwrite     ( hwrite    ),  // ahb master write signal
        .htrans     ( htrans    ),  // ahb master transfer control signal
        .hsize      ( hsize     ),  // ahb master size signal
        .hburst     ( hburst    ),  // ahb master burst signal
        .hresp      ( hresp     ),  // ahb master response signal
        .hready     ( hready    ),  // ahb master ready signal
        // Slaves side
        .haddr_s    ( haddr_s   ),  // ahb slave address
        .hrdata_s   ( hrdata_s  ),  // ahb slave read data
        .hwdata_s   ( hwdata_s  ),  // ahb slave write data
        .hwrite_s   ( hwrite_s  ),  // ahb slave write signal
        .htrans_s   ( htrans_s  ),  // ahb slave transfer control signal
        .hsize_s    ( hsize_s   ),  // ahb slave size signal
        .hburst_s   ( hburst_s  ),  // ahb slave burst signal
        .hresp_s    ( hresp_s   ),  // ahb slave response signal
        .hready_s   ( hready_s  ),  // ahb slave ready signal
        .hsel_s     ( hsel_s    )   // ahb slave select signal
    );

    task write_data(logic [31 : 0] wr_addr, logic [31 : 0] wr_data);
        logic [31 : 0] wr_data_h;
        haddr = wr_addr;
        hwrite = '1;
        htrans = '1;
        @(posedge hclk);
        htrans = '0;
        wr_data_h = wr_data;
        fork
            begin
                data_wq.push_back(wr_data_h);
                hwdata = wr_data_h;
            end
        join_none
    endtask : write_data

    task read_data(logic [31 : 0] rd_addr);
        logic [31 : 0] rd_addr_h;
        haddr = rd_addr;
        hwrite = '0;
        htrans = '1;
        @(posedge hclk);
        htrans = '0;
        rd_addr_h = rd_addr;
        fork
            begin
                @(posedge hclk);
                data_rq.push_back(hrdata);
                $display("rd_addr = 0x%h, rd_data = 0x%h", rd_addr_h, hrdata );
            end
        join_none
    endtask : read_data

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
        haddr = '0;
        hwdata = '0;
        hwrite = '0;
        htrans = '0;
        hsize = '0;
        hburst = '0;
        repeat(repeat_n) 
        begin
            int wr_addr;
            int wr_data;
            wr_addr = $urandom_range(0,32'h0003_FFFF);
            wr_addr = wr_addr & (~3);
            wr_data = $random();
            addr_q.push_back(wr_addr);
            $display("wr_addr = 0x%h, wr_data = 0x%h", wr_addr, wr_data);
            write_data(wr_addr,wr_data);
        end
        for(;addr_q.size != 0;)
            read_data(addr_q.pop_front());
        repeat(20) @(posedge hclk);
        for(;data_rq.size != 0;)
        begin
            integer data_r;
            integer data_w;
            data_r = data_rq.pop_front();
            data_w = data_wq.pop_front();
            if( data_r != data_w )
                $display("Error wr_data = 0x%h, rd_data = 0x%h", data_w, data_r );
        end
        $stop;
    end

    genvar ahb_i;

    generate
        for( ahb_i = 0 ; ahb_i < slv_c ; ahb_i++ )
        begin
            initial
            begin
                # start_del;
                forever
                begin
                    @(posedge hclk);
                    if( hwrite_s[ahb_i] && hsel_s[ahb_i] && ( htrans_s[ahb_i] != '0 ) )
                    fork
                        begin

                            logic [31 : 0] haddr_s_h;
                            haddr_s_h = haddr_s[ahb_i];
                            @(posedge hclk);
                            slv[ahb_i][haddr_s_h & slv_m[ahb_i]] = hwdata_s[ahb_i];
                            $display("slv[%0d][0x%8h] = 0x%8h", ahb_i, haddr_s_h & slv_m[ahb_i], slv[ahb_i][haddr_s_h & slv_m[ahb_i]]);
                        end
                    join_none
                    else if( ( ! hwrite_s[ahb_i] ) && hsel_s[ahb_i] && ( htrans_s[ahb_i] != '0 ) )
                        hrdata_s[ahb_i] = slv[ahb_i][haddr_s[ahb_i] & slv_m[ahb_i]];
                end
            end
        end
    endgenerate

endmodule : ahb_router_tb
