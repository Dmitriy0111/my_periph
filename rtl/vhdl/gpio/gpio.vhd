--
-- File         : gpio.vhd
-- Autor        : Vlasov D.V.
-- Data         : 18.02.2021
-- Language     : VHDL
-- Description  : This is gpio module
-- Copyright(c) : 2021 Vlasov D.V.
--

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.common_pkg.all;
use work.regs_pkg.all;
use work.gpio_pkg.all;

entity gpio_vhd is
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
end;

architecture rtl of gpio_vhd is
    -- internal regs
    signal gpi_int_0    : std_logic_vector(GPIO_W-1 downto 0);
    signal gpi_int_1    : std_logic_vector(GPIO_W-1 downto 0);
    signal gpi_int_2    : std_logic_vector(GPIO_W-1 downto 0);
    signal gpo_int      : std_logic_vector(GPIO_W-1 downto 0);
    signal gpd_int      : std_logic_vector(GPIO_W-1 downto 0);
    signal alt          : std_logic_vector(GPIO_W-1 downto 0);
    signal irq_m        : std_logic_vector(GPIO_W-1 downto 0);
    signal irq_t        : std_logic_vector(GPIO_W-1 downto 0);
    signal irq_v        : std_logic_vector(GPIO_W-1 downto 0);
    signal cap          : std_logic_vector(GPIO_W-1 downto 0);
    signal irq_v_f      : std_logic_vector(GPIO_W-1 downto 0);
    -- irqs events
    signal pos_event    : std_logic_vector(GPIO_W-1 downto 0);
    signal neg_event    : std_logic_vector(GPIO_W-1 downto 0);
    signal hi_event     : std_logic_vector(GPIO_W-1 downto 0);
    signal lo_event     : std_logic_vector(GPIO_W-1 downto 0);
    -- write enable signals
    signal gpo_we     : std_logic;
    signal gpd_we     : std_logic;
    signal alt_we     : std_logic;
    signal irq_m_we   : std_logic;
    signal irq_t_we   : std_logic;
    signal irq_v_we   : std_logic;
    signal irq_v_we_f : std_logic_vector(GPIO_W-1 downto 0);
    signal cap_we     : std_logic;
begin

    assert ( ADDR_W >= GPIO_W ) report "ADDR and GPIO width error!" severity error;

    alt_n_gen : if not ALT_U generate
        ALT_i <= (others => '0');
        GPO <= gpo_int;
        GPD <= gpd_int;
    end generate alt_n_gen;

    alt_gen : if ALT_U generate
        ALT_i <= GPI;
        alt_con_gen : for i in GPIO_W-1 downto 0 generate
            GPO(i) <= ALT_o(i) when alt(i) else gpo_int(i);
            GPD(i) <= ALT_d(i) when alt(i) else gpd_int(i);
        end generate alt_con_gen;
    end generate alt_gen;
    -- assign interrupt
    IRQ <= or_all(irq_v) when IRQ_U else '0';
    -- assign write enable signals
    gpo_we   <= find_we( ADDR , GPIO_GPO   , WE );
    gpd_we   <= find_we( ADDR , GPIO_GPD   , WE );
    alt_we   <= find_we( ADDR , GPIO_ALT   , WE );
    irq_m_we <= find_we( ADDR , GPIO_IRQ_M , WE );
    irq_t_we <= find_we( ADDR , GPIO_IRQ_T , WE );
    irq_v_we <= find_we( ADDR , GPIO_IRQ_V , WE );
    cap_we   <= find_we( ADDR , GPIO_CAP   , WE );
    -- assign events
    pos_event <= ( not gpi_int_2 ) and (     gpi_int_1 ) and irq_m and (     irq_t ) and (     cap );
    neg_event <= (     gpi_int_2 ) and ( not gpi_int_1 ) and irq_m and (     irq_t ) and ( not cap );
    hi_event  <= ( not gpi_int_2 ) and                       irq_m and ( not irq_t ) and (     cap );
    lo_event  <= (     gpi_int_2 ) and                       irq_m and ( not irq_t ) and ( not cap );

    irq_v_we_f <= pos_event or neg_event or hi_event or lo_event or rep_sl(irq_v_we, GPIO_W);

    process (all)
    begin
        RD <= ( DATA_W-GPIO_W-1 downto 0 => '0') & sel_slv(gpi_int_2,gpi_int_0,IRQ_U);
        case( ADDR(4 downto 0) ) is
            when GPIO_GPI   => RD <= ( DATA_W-GPIO_W-1 downto 0 => '0') & sel_slv(gpi_int_2,gpi_int_0,IRQ_U);
            when GPIO_GPO   => RD <= ( DATA_W-GPIO_W-1 downto 0 => '0') & gpo_int;
            when GPIO_GPD   => RD <= ( DATA_W-GPIO_W-1 downto 0 => '0') & gpd_int;
            when GPIO_ALT   => RD <= ( DATA_W-GPIO_W-1 downto 0 => '0') & sel_slv(alt  ,gpi_int_0,ALT_U);
            when GPIO_IRQ_M => RD <= ( DATA_W-GPIO_W-1 downto 0 => '0') & sel_slv(irq_m,gpi_int_0,IRQ_U);
            when GPIO_IRQ_T => RD <= ( DATA_W-GPIO_W-1 downto 0 => '0') & sel_slv(irq_t,gpi_int_0,IRQ_U);
            when GPIO_CAP   => RD <= ( DATA_W-GPIO_W-1 downto 0 => '0') & sel_slv(cap  ,gpi_int_0,IRQ_U);
            when GPIO_IRQ_V => RD <= ( DATA_W-GPIO_W-1 downto 0 => '0') & sel_slv(irq_v,gpi_int_0,IRQ_U);
            when others     => RD <= ( DATA_W-GPIO_W-1 downto 0 => '0') & sel_slv(gpi_int_2,gpi_int_0,IRQ_U);
        end case;
    end process;

    gpo_reg     : reg_we_vhd generic map( GPIO_W, RST_T, RST_P ) 
                             port    map( CLK, RST, gpo_we, WD(GPIO_W-1 downto 0), gpo_int);

    gpd_reg     : reg_we_vhd generic map( GPIO_W, RST_T, RST_P ) 
                             port    map( CLK, RST, gpd_we, WD(GPIO_W-1 downto 0), gpd_int);
    
    alt_reg_gen : if ALT_U generate
        alt_reg     : reg_we_vhd generic map( GPIO_W, RST_T, RST_P ) 
                                 port    map( CLK, RST, alt_we, WD(GPIO_W-1 downto 0), alt);
    end generate alt_reg_gen;

    gpi_0_reg   : reg_we_vhd generic map( GPIO_W, RST_T, RST_P ) 
                             port    map( CLK, RST, '1', GPI, gpi_int_0);

    irq_gen : if IRQ_U generate
        gpi_1_reg   : reg_we_vhd generic map( GPIO_W, RST_T, RST_P ) 
                                 port    map( CLK, RST, '1', gpi_int_0, gpi_int_1);

        gpi_2_reg   : reg_we_vhd generic map( GPIO_W, RST_T, RST_P ) 
                                 port    map( CLK, RST, '1', gpi_int_1, gpi_int_2);

        irq_m_reg   : reg_we_vhd generic map( GPIO_W, RST_T, RST_P ) 
                                 port    map( CLK, RST, irq_m_we, WD(GPIO_W-1 downto 0), irq_m);

        irq_t_reg   : reg_we_vhd generic map( GPIO_W, RST_T, RST_P ) 
                                 port    map( CLK, RST, irq_t_we, WD(GPIO_W-1 downto 0), irq_t);

        cap_reg     : reg_we_vhd generic map( GPIO_W, RST_T, RST_P )
                                 port    map( CLK, RST, cap_we, WD(GPIO_W-1 downto 0), cap);

        irq_reg_gen : for i in GPIO_W-1 downto 0 generate
            irq_v_f(i) <= '1' when ( pos_event(i) or neg_event(i) or hi_event(i) or lo_event(i) ) else WD(i);

            irq_v_reg   : reg_we_vhd generic map( 1, RST_T, RST_P ) 
                                     port    map( CLK, RST, irq_v_we_f(i), ( 0 => irq_v_f(i) ), PDO(0) => irq_v(i) );
        end generate irq_reg_gen;
    end generate irq_gen;

end rtl ; -- rtl
