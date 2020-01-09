/*
*  File            :   avalon_mon.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2020.01.09
*  Language        :   SystemVerilog
*  Description     :   This is avalon interface monitor 
*  Copyright(c)    :   2019 - 2020 Vlasov D.V.
*/

`ifndef AVALON_MON__SV
`define AVALON_MON__SV

class avalon_mon extends dvv_mon #(ctrl_trans);
    `OBJ_BEGIN( avalon_mon )

    virtual avalon_if   vif;

    avalon_mth          mth;

    extern function new(string name = "", dvv_bc parent = null);

    extern task     build();
    extern task     run();
    
endclass : avalon_mon

function avalon_mon::new(string name = "", dvv_bc parent = null);
    super.new(name,parent);
endfunction : new

task avalon_mon::build();
    if( !dvv_res_db#(virtual avalon_if)::get_res_db("avalon_if_0",vif) )
        $fatal();

    mth = avalon_mth::create::create_obj("[ AVALON MON MTH ]", this);
    mth.vif = vif;

    $display("%s build complete", this.fname);
endtask : build

task avalon_mon::run();
    forever
    begin
        mth.wait_clk();
        #0;
        if( mth.write_detect() )
        begin
            $display("WRITE_TR addr = 0x%h, data = 0x%h", mth.get_address(), mth.get_writedata());
        end
        else if( mth.read_detect() )
        begin
            fork
                mth.wait_clk();
                $display("READ_TR  addr = 0x%h, data = 0x%h", mth.get_address(), mth.get_readdata());
            join_none
        end
    end
endtask : run

`endif // AVALON_MON__SV
