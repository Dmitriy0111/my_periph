--
-- File         : regs_pkg.vhd
-- Autor        : Vlasov D.V.
-- Data         : 18.02.2021
-- Language     : VHDL
-- Description  : This regs package
-- Copyright(c) : 2021 Vlasov D.V.
--

library ieee;
use ieee.std_logic_1164.all;

package regs_pkg is

    component reg_vhd is
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
            --
            PDI     : in    std_logic_vector(DATA_W-1 downto 0);
            PDO     : out   std_logic_vector(DATA_W-1 downto 0)
        );
    end component;

    component reg_we_vhd is
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
            --
            WE      : in    std_logic;
            PDI     : in    std_logic_vector(DATA_W-1 downto 0);
            PDO     : out   std_logic_vector(DATA_W-1 downto 0)
        );
    end component;

    component reg_clr_vhd is
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
            --
            CLR     : in    std_logic;
            PDI     : in    std_logic_vector(DATA_W-1 downto 0);
            PDO     : out   std_logic_vector(DATA_W-1 downto 0)
        );
    end component;

    component reg_we_clr_vhd is
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
            --
            WE      : in    std_logic;
            CLR     : in    std_logic;
            PDI     : in    std_logic_vector(DATA_W-1 downto 0);
            PDO     : out   std_logic_vector(DATA_W-1 downto 0)
        );
    end component;    
    
end package regs_pkg;
