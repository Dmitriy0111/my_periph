/*
*  File            :   mem_pkg.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2019.12.21
*  Language        :   SystemVerilog
*  Description     :   This is memory module
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

package mem_pkg;

    parameter 
    logic   [47 : 0]    mem_iv[7 : 0] = 
    '{
        64'h00000000_AAAAAAAA,
        64'h00000001_55555555,
        64'h00000002_00000000,
        64'h00000003_FFFFFFFF,
        64'h00000004_77777777,
        64'h00000005_88888888,
        64'h00000006_EEEEEEEE,
        64'h00000007_11111111
    };
    
endpackage : mem_pkg
