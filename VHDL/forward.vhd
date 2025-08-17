LIBRARY IEEE; 		
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY forward IS
    generic(
        DATA_BUS_WIDTH : integer := 32
    );
   PORT( 	
		r1_addr_i       : in    std_logic_vector(4 downto 0);
        r2_addr_i       : in    std_logic_vector(4 downto 0);
        wb_addr_mem_i   : in    std_logic_vector(4 downto 0);
        wb_addr_wb_i    : in    std_logic_vector(4 downto 0);
        reg_wr_mem_i    : in    std_logic;
        reg_wr_wb_i     : in    std_logic;
        mem_read_i      : in    std_logic;
        r1_mux_o        : out   std_logic_vector(1 downto 0);
        r2_mux_o        : out   std_logic_vector(1 downto 0)
	);
END forward;

architecture forward_arch of forward is

begin
    -- register 1
    r1_mux_o <= "01" when (r1_addr_i=wb_addr_mem_i) and reg_wr_mem_i='1' and (wb_addr_mem_i/="00000") and (mem_read_i='0') else
                "10" when (r1_addr_i=wb_addr_wb_i) and reg_wr_wb_i='1' and (wb_addr_wb_i/="00000") else
                "00";

    -- register 2
    r2_mux_o <= "01" when (r2_addr_i=wb_addr_mem_i) and reg_wr_mem_i='1' else
                "10" when (r2_addr_i=wb_addr_wb_i) and reg_wr_wb_i='1' else
                "00";
end architecture;