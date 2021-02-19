--
-- File         : gpio_pkg.vhd
-- Autor        : Vlasov D.V.
-- Data         : 18.02.2021
-- Language     : VHDL
-- Description  : This is gpio package
-- Copyright(c) : 2021 Vlasov D.V.
--

library ieee;
use ieee.std_logic_1164.all;

package gpio_pkg is

    constant GPIO_GPI   : std_logic_vector(4 downto 0) := 5X"00";
    constant GPIO_GPO   : std_logic_vector(4 downto 0) := 5X"04";
    constant GPIO_GPD   : std_logic_vector(4 downto 0) := 5X"08";
    constant GPIO_ALT   : std_logic_vector(4 downto 0) := 5X"0C";
    constant GPIO_IRQ_M : std_logic_vector(4 downto 0) := 5X"10";
    constant GPIO_IRQ_T : std_logic_vector(4 downto 0) := 5X"14";
    constant GPIO_CAP   : std_logic_vector(4 downto 0) := 5X"18";
    constant GPIO_IRQ_V : std_logic_vector(4 downto 0) := 5X"1C";

    function find_we(addr_v : std_logic_vector; addr_c : std_logic_vector; we_v : std_logic) return std_logic;

    component gpio_vhd is
        generic
        (
            ADDR_W  : integer := 32;
            DATA_W  : integer := 32;
            GPIO_W  : integer := 8;
            RST_T   : string  := "ASYNC";
            RST_P   : string  := "LOW";
            IRQ_U   : boolean := true;
            ALT_U   : boolean := true
        );
        port
        (
            -- Clock and reset
            CLK     : in    std_logic;
            RST     : in    std_logic;
            -- Simple interface
            ADDR    : in    std_logic_vector(ADDR_W-1 downto 0);
            WE      : in    std_logic;
            WD      : in    std_logic_vector(DATA_W-1 downto 0);
            RD      : out   std_logic_vector(DATA_W-1 downto 0);
            -- IRQ
            IRQ     : out   std_logic;
            -- Alternative
            ALT_i   : out   std_logic_vector(GPIO_W-1 downto 0);
            ALT_o   : in    std_logic_vector(GPIO_W-1 downto 0);
            ALT_d   : in    std_logic_vector(GPIO_W-1 downto 0);
            -- GPIO pins
            GPI     : in    std_logic_vector(GPIO_W-1 downto 0);
            GPO     : out   std_logic_vector(GPIO_W-1 downto 0);
            GPD     : out   std_logic_vector(GPIO_W-1 downto 0)
        );
    end component;
    
end package gpio_pkg;

package body gpio_pkg is

    function find_we(addr_v : std_logic_vector; addr_c : std_logic_vector; we_v : std_logic) return std_logic is
        variable ret_sl : std_logic;
    begin
        if( ( addr_v(addr_c'range ) = addr_c ) and ( we_v = '1' ) ) then
            ret_sl := '1';
        else
            ret_sl := '0';
        end if;
        
        return ret_sl;
    end function find_we;

end;
