/*
*  File            :   mem.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.21
*  Language        :   SystemVerilog
*  Description     :   This is memory module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module mem
#(
    parameter                       depth = 8,
                                    a_w = $clog2(depth),
                                    d_w = 32,
                                    b_c = 4,
                                    mem_init = 0,
                                    init_s = 1,

    parameter
            logic   [d_w+a_w-1 : 0] mem_v   [init_s-1 : 0] = {'0}
)(
    // clock
    input   logic   [0     : 0]     clk,    // clock
    // bus side
    input   logic   [a_w-1 : 0]     addr,   // address
    input   logic   [b_c-1 : 0]     we,     // write enable
    input   logic   [d_w-1 : 0]     wd,     // write data
    output  logic   [d_w-1 : 0]     rd      // read data
);
    
    localparam      mem_step = d_w / b_c;
    

    genvar mem_i;
    
    generate
        for( mem_i = 0 ; mem_i < b_c ; mem_i ++ )
        begin : gen_mem_we

            logic   [mem_step-1 : 0]  mem_a   [depth-1 : 0];

            assign rd[mem_i * mem_step +: mem_step] = mem_a[addr];

            always_ff @(posedge clk)
                if( we[mem_i] )
                    mem_a[addr] <= wd[mem_i * mem_step +: mem_step];

            initial
            begin
                logic   [a_w-1      : 0]    init_addr;
                logic   [mem_step-1 : 0]    init_data;
                if( mem_init )
                    for( int i = 0 ; i < init_s ; i++ )
                    begin
                        init_addr = mem_v[i][d_w +: a_w];
                        init_data = mem_v[i][mem_i * mem_step +: mem_step];
                        mem_a[init_addr] = init_data;
                    end
            end

        end
    endgenerate

endmodule : mem
