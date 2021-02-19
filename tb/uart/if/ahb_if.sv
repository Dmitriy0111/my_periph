/*
*  File            :   ahb_if.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.09
*  Language        :   SystemVerilog
*  Description     :   This is ahb interface
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

interface ahb_if
(
    input   logic   [0 : 0]     hclk,
    input   logic   [0 : 0]     hresetn
);

    // bus side
    logic   [31 : 0]    haddr;      // ahb address
    logic   [31 : 0]    hrdata;     // ahb read data
    logic   [31 : 0]    hwdata;     // ahb write data
    logic   [0  : 0]    hwrite;     // ahb write signal
    logic   [1  : 0]    htrans;     // ahb transfer control signal
    logic   [2  : 0]    hsize;      // ahb size signal
    logic   [2  : 0]    hburst;     // ahb burst signal
    logic   [1  : 0]    hresp;      // ahb response signal
    logic   [0  : 0]    hready;     // ahb ready signal
    logic   [0  : 0]    hsel;       // ahb select signal

endinterface : ahb_if
