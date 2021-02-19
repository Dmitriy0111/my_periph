--
-- File         : common_pkg.vhd
-- Autor        : Vlasov D.V.
-- Data         : 17.02.2021
-- Language     : VHDL
-- Description  : This common package
-- Copyright(c) : 2021 Vlasov D.V.
--

library ieee;
use ieee.std_logic_1164.all;

package common_pkg is

    function pol_dec(pt : string) return std_logic;

    function sel_slv(slv_t : std_logic_vector; slv_f : std_logic_vector; sel : boolean) return std_logic_vector;

    function rep_sl(sl : std_logic; rep : integer) return std_logic_vector;

    function or_all(slv : std_logic_vector) return std_logic;

    function and_all(slv : std_logic_vector) return std_logic;
    
end package common_pkg;

package body common_pkg is

    function pol_dec(pt : string) return std_logic is
        variable ret_pol : std_logic;
    begin
        if((pt = "HIGH")) then
            ret_pol := '1';
        else
            ret_pol := '0';
        end if;
        return ret_pol;
    end function pol_dec;

    function sel_slv(slv_t : std_logic_vector; slv_f : std_logic_vector; sel : boolean) return std_logic_vector is
        variable ret_slv : std_logic_vector(slv_t'range);
    begin
        if( sel ) then
            ret_slv := slv_t;
        else
            ret_slv := slv_f;
        end if;

        return ret_slv;
    end function sel_slv;

    function rep_sl(sl : std_logic; rep : integer) return std_logic_vector is
        variable ret_slv : std_logic_vector(rep-1 downto 0);
    begin
        for i in 0 to rep-1 loop
            ret_slv(i) := sl;
        end loop;
        return ret_slv;
    end function rep_sl;

    function or_all(slv : std_logic_vector) return std_logic is
        variable ret_sl : std_logic := '0';
    begin
        for i in slv'range loop
            ret_sl := ret_sl or slv(i);
        end loop;
        return ret_sl;
    end function or_all;

    function and_all(slv : std_logic_vector) return std_logic is
        variable ret_sl : std_logic := '1';
    begin
        for i in slv'range loop
            ret_sl := ret_sl and slv(i);
        end loop;
        return ret_sl;
    end function and_all;

end;
