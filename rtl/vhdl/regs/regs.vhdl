--
-- File         : regs.vhd
-- Autor        : Vlasov D.V.
-- Data         : 18.02.2021
-- Language     : VHDL
-- Description  : This is registers module
-- Copyright(c) : 2021 Vlasov D.V.
--

-------------------------------------------------------------------------------
-- reg                                                                       --
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.common_pkg.all;

entity reg_vhd is
    generic
    (
        DATA_W  : integer := 32;
        RST_T   : string  := "SYNC";
        RST_P   : string  := "LOW"
    );
    port
    (
        -- Clock and reset
        CLK     : in    std_logic;
        RST     : in    std_logic;
        -- Data and control
        PDI     : in    std_logic_vector(DATA_W-1 downto 0);
        PDO     : out   std_logic_vector(DATA_W-1 downto 0)
    );
end;

architecture rtl of reg_vhd is
    constant this_rst_val : std_logic := pol_dec(RST_P);
begin

    assert ( (RST_T = "SYNC") or (RST_T = "ASYNC") ) report "Reset synchronisation type error!" severity error;

    SYNC_LOGIC : if (RST_T = "SYNC") generate
        process(CLK, RST)
        begin
            if( rising_edge(CLK) ) then
                if( RST = this_rst_val ) then
                    PDO <= (others => '0');
                else
                    PDO <= PDI;
                end if;
            end if;
        end process;
    end generate SYNC_LOGIC;

    ASYNC_LOGIC : if (RST_T = "ASYNC") generate
        process(CLK, RST)
        begin
            if( RST = this_rst_val ) then
                PDO <= (others => '0');
            else
                if( rising_edge(CLK) ) then
                    PDO <= PDI;
                end if;
            end if;
        end process;
    end generate ASYNC_LOGIC;
	 
end rtl ; -- rtl

-------------------------------------------------------------------------------
-- reg_we                                                                    --
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.common_pkg.all;

entity reg_we_vhd is
    generic
    (
        DATA_W  : integer := 32;
        RST_T   : string  := "SYNC";
        RST_P   : string  := "LOW"
    );
    port
    (
        -- Clock and reset
        CLK     : in    std_logic;
        RST     : in    std_logic;
        -- Data and control
        WE      : in    std_logic;
        PDI     : in    std_logic_vector(DATA_W-1 downto 0);
        PDO     : out   std_logic_vector(DATA_W-1 downto 0)
    );
end;

architecture rtl of reg_we_vhd is
    constant this_rst_val : std_logic := pol_dec(RST_P);
begin

    assert ( (RST_T = "SYNC") or (RST_T = "ASYNC") ) report "Reset synchronisation type error!" severity error;

    SYNC_LOGIC : if (RST_T = "SYNC") generate
        process(CLK, RST)
        begin
            if( rising_edge(CLK) ) then
                if( RST = this_rst_val ) then
                    PDO <= (others => '0');
                else
                    if( WE = '1' ) then
                        PDO <= PDI;
                    end if;
                end if;
            end if;
        end process;
    end generate SYNC_LOGIC;

    ASYNC_LOGIC : if (RST_T = "ASYNC") generate
        process(CLK, RST)
        begin
            if( RST = this_rst_val ) then
                PDO <= (others => '0');
            else
                if( rising_edge(CLK) ) then
                    if( WE = '1' ) then
                        PDO <= PDI;
                    end if;
                end if;
            end if;
        end process;
    end generate ASYNC_LOGIC;
	 
end rtl ; -- rtl

-------------------------------------------------------------------------------
-- reg_clr                                                                   --
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.common_pkg.all;

entity reg_clr_vhd is
    generic
    (
        DATA_W  : integer := 32;
        RST_T   : string  := "SYNC";
        RST_P   : string  := "LOW"
    );
    port
    (
        -- Clock and reset
        CLK     : in    std_logic;
        RST     : in    std_logic;
        -- Data and control
        CLR     : in    std_logic;
        PDI     : in    std_logic_vector(DATA_W-1 downto 0);
        PDO     : out   std_logic_vector(DATA_W-1 downto 0)
    );
end;

architecture rtl of reg_clr_vhd is
    constant this_rst_val : std_logic := pol_dec(RST_P);
begin

    assert ( (RST_T = "SYNC") or (RST_T = "ASYNC") ) report "Reset synchronisation type error!" severity error;

    SYNC_LOGIC : if (RST_T = "SYNC") generate
        process(CLK, RST)
        begin
            if( rising_edge(CLK) ) then
                if( RST = this_rst_val ) then
                    PDO <= (others => '0');
                else
                    if( CLR = '1' ) then
                        PDO <= (others => '0');
                    else
                        PDO <= PDI;
                    end if;
                end if;
            end if;
        end process;
    end generate SYNC_LOGIC;

    ASYNC_LOGIC : if (RST_T = "ASYNC") generate
        process(CLK, RST)
        begin
            if( RST = this_rst_val ) then
                PDO <= (others => '0');
            else
                if( rising_edge(CLK) ) then
                    if( CLR = '1' ) then
                        PDO <= (others => '0');
                    else
                        PDO <= PDI;
                    end if;
                end if;
            end if;
        end process;
    end generate ASYNC_LOGIC;
	 
end rtl ; -- rtl

-------------------------------------------------------------------------------
-- reg_we_clr                                                                --
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.common_pkg.all;

entity reg_we_clr_vhd is
    generic
    (
        DATA_W  : integer := 32;
        RST_T   : string  := "SYNC";
        RST_P   : string  := "LOW"
    );
    port
    (
        -- Clock and reset
        CLK     : in    std_logic;
        RST     : in    std_logic;
        -- Data and control
        WE      : in    std_logic;
        CLR     : in    std_logic;
        PDI     : in    std_logic_vector(DATA_W-1 downto 0);
        PDO     : out   std_logic_vector(DATA_W-1 downto 0)
    );
end;

architecture rtl of reg_we_clr_vhd is
    constant this_rst_val : std_logic := pol_dec(RST_P);
begin

    assert ( (RST_T = "SYNC") or (RST_T = "ASYNC") ) report "Reset synchronisation type error!" severity error;

    SYNC_LOGIC : if (RST_T = "SYNC") generate
        process(CLK, RST)
        begin
            if( rising_edge(CLK) ) then
                if( RST = this_rst_val ) then
                    PDO <= (others => '0');
                else
                    if( WE = '1' ) then
                        if( CLR = '1' ) then
                            PDO <= (others => '0');
                        else
                            PDO <= PDI;
                        end if;
                    end if;
                end if;
            end if;
        end process;
    end generate SYNC_LOGIC;

    ASYNC_LOGIC : if (RST_T = "ASYNC") generate
        process(CLK, RST)
        begin
            if( RST = this_rst_val ) then
                PDO <= (others => '0');
            else
                if( rising_edge(CLK) ) then
                    if( WE = '1' ) then
                        if( CLR = '1' ) then
                            PDO <= (others => '0');
                        else
                            PDO <= PDI;
                        end if;
                    end if;
                end if;
            end if;
        end process;
    end generate ASYNC_LOGIC;
 
end rtl ; -- rtl
