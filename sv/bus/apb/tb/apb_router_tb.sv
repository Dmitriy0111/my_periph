/* 
*  File            :   apb_router_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.23
*  Language        :   SystemVerilog
*  Description     :   This apb router testbench
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module apb_router_tb();

    timeprecision                       1ns;
    timeunit                            1ns;

    parameter                           T = 10,
                                        start_del = 200,
                                        rst_delay = 7,
                                        repeat_n = 20;

    parameter                           slv_c = 4,
                                        a_w = 12;

    // clock and reset
    logic                [0     : 0]    pclk;           // pclk
    logic                [0     : 0]    presetn;        // presetn
    // APB master side
    logic   [slv_c-1 : 0][a_w-1 : 0]    paddr_am;       // apb master address mask
    logic                [a_w-1 : 0]    paddr;          // apb master address
    logic                [31    : 0]    prdata;         // apb master read data
    logic                [31    : 0]    pwdata;         // apb master write data
    logic                [0     : 0]    psel;           // apb master select
    logic                [0     : 0]    pwrite;         // apb master write
    logic                [0     : 0]    penable;        // apb master enable
    logic                [0     : 0]    pready;         // apb master ready
    // APB slave side
    logic   [slv_c-1 : 0][a_w-1 : 0]    paddr_s;        // apb slave address
    logic   [slv_c-1 : 0][31    : 0]    prdata_s;       // apb slave read data
    logic   [slv_c-1 : 0][31    : 0]    pwdata_s;       // apb slave write data
    logic   [slv_c-1 : 0][0     : 0]    psel_s;         // apb slave select
    logic   [slv_c-1 : 0][0     : 0]    pwrite_s;       // apb slave write
    logic   [slv_c-1 : 0][0     : 0]    penable_s;      // apb slave enable
    logic   [slv_c-1 : 0][0     : 0]    pready_s;       // apb slave ready

    logic                [31    : 0]    slv     [slv_c][1024];

    bit     [slv_c-1 : 0][a_w-1 : 0]    slv_m;

    integer                             addr_q  [$];
    logic   [31 : 0]                    data_wq [integer];
    logic   [31 : 0]                    data_rq [integer];

    assign paddr_am =   
                        { 
                            { 12'b11xx_xxxx_xxxx },
                            { 12'b10xx_xxxx_xxxx },
                            { 12'b01xx_xxxx_xxxx },
                            { 12'b00xx_xxxx_xxxx }
                        };

    assign slv_m =      
                        { 
                            { 12'b0011_1111_1111 },
                            { 12'b0011_1111_1111 },
                            { 12'b0011_1111_1111 },
                            { 12'b0011_1111_1111 }
                        };

    apb_router 
    #(
        .slv_c      ( slv_c     ),
        .a_w        ( a_w       )
    )
    dut
    (
        // clock and reset
        .pclk       ( pclk      ),  // pclk
        .presetn    ( presetn   ),  // presetn
        // APB master side
        .paddr_am   ( paddr_am  ),  // apb master address mask
        .paddr      ( paddr     ),  // apb master address
        .prdata     ( prdata    ),  // apb master read data
        .pwdata     ( pwdata    ),  // apb master write data
        .psel       ( psel      ),  // apb master select
        .pwrite     ( pwrite    ),  // apb master write
        .penable    ( penable   ),  // apb master enable
        .pready     ( pready    ),  // apb master ready
        // APB slave side
        .paddr_s    ( paddr_s   ),  // apb slave address
        .prdata_s   ( prdata_s  ),  // apb slave read data
        .pwdata_s   ( pwdata_s  ),  // apb slave write data
        .psel_s     ( psel_s    ),  // apb slave select
        .pwrite_s   ( pwrite_s  ),  // apb slave write
        .penable_s  ( penable_s ),  // apb slave enable
        .pready_s   ( pready_s  )   // apb slave ready
    );

    task write_data(logic [31 : 0] wr_addr, logic [31 : 0] wr_data);
        paddr = wr_addr;
        pwrite = '1;
        psel = '1;
        penable = '0;
        pwdata = wr_data;
        data_wq[wr_addr] = wr_data;
        @(posedge pclk);
        penable = '1;
        @(posedge pclk);
        psel = '0;
        penable = '0;
    endtask : write_data

    task read_data(logic [31 : 0] rd_addr);
        paddr = rd_addr;
        pwrite = '0;
        psel = '1;
        @(posedge pclk);
        penable = '1;
        @(posedge pclk);
        psel = '0;
        penable = '0;
        data_rq[paddr] = prdata;
        $display("rd_addr = 0x%h, rd_data = 0x%h", rd_addr, prdata );
    endtask : read_data

    initial
    begin
        # start_del;
        pclk = '0;
        forever
            #(T/2) pclk <= !pclk;
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
        @(posedge presetn);
        paddr = '0;
        pwdata = '0;
        pwrite = '0;
        psel = '0;
        repeat(repeat_n) 
        begin
            int wr_addr;
            int wr_data;
            wr_addr = $urandom_range(0,32'h0000_0FFF);
            wr_addr = wr_addr & (~3);
            wr_data = $random();
            addr_q.push_back(wr_addr);
            $display("wr_addr = 0x%h, wr_data = 0x%h", wr_addr, wr_data);
            write_data(wr_addr,wr_data);
        end
        for( int i = 0 ; i < addr_q.size ; i++ )
            read_data(addr_q[i]);
        repeat(20) @(posedge pclk);
        for(;addr_q.size != 0;)
        begin
            integer addr;
            addr = addr_q.pop_front();
            if( data_rq[addr] != data_wq[addr] )
                $display("Error wr_data = 0x%h, rd_data = 0x%h", data_rq[addr], data_wq[addr] );
            else
                $display("Pass  wr_data = 0x%h, rd_data = 0x%h", data_rq[addr], data_wq[addr] );
        end
        $stop;
    end

    genvar apb_i;

    generate
        for( apb_i = 0 ; apb_i < slv_c ; apb_i++ )
        begin
            initial
            begin
                # start_del;
                forever
                begin
                    @(posedge pclk);
                    if( pwrite_s[apb_i] && psel_s[apb_i] && penable_s[apb_i] )
                    begin
                        slv[apb_i][paddr_s[apb_i] & slv_m[apb_i]] = pwdata_s[apb_i];
                        $display("slv[%0d][0x%8h] = 0x%8h", apb_i, paddr_s[apb_i] & slv_m[apb_i], slv[apb_i][paddr_s[apb_i] & slv_m[apb_i]]);
                    end
                    else if( ( ! pwrite_s[apb_i] ) && psel_s[apb_i] )
                        prdata_s[apb_i] = slv[apb_i][paddr_s[apb_i] & slv_m[apb_i]];
                end
            end
        end
    endgenerate

endmodule : apb_router_tb
