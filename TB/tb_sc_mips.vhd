---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;
USE work.cond_comilation_package.all;
USE work.aux_package.all;


ENTITY MIPS_tb IS
	generic( 
		WORD_GRANULARITY : boolean 	:= G_WORD_GRANULARITY;
	    MODELSIM : integer 			:= G_MODELSIM;
		DATA_BUS_WIDTH : integer 	:= 32;
		ITCM_ADDR_WIDTH : integer 	:= G_ADDRWIDTH;
		DTCM_ADDR_WIDTH : integer 	:= G_ADDRWIDTH;
		PC_WIDTH : integer 			:= 10;
		FUNCT_WIDTH : integer 		:= 6;
		DATA_WORDS_NUM : integer 	:= G_DATA_WORDS_NUM;
		CLK_CNT_WIDTH : integer 	:= 16;
		INST_CNT_WIDTH : integer 	:= 16
	);
END MIPS_tb ;


ARCHITECTURE struct OF MIPS_tb IS
   -- Internal signal declarations
   SIGNAL rst_tb_i           	: STD_LOGIC;
   SIGNAL clk_tb_i           	: STD_LOGIC;
   
   signal IFpc_o				: std_logic_vector(PC_WIDTH-1 downto 0);
   signal IDpc_o				: std_logic_vector(PC_WIDTH-1 downto 0);
   signal EXpc_o				: std_logic_vector(PC_WIDTH-1 downto 0);
   signal MEMpc_o				: std_logic_vector(PC_WIDTH-1 downto 0);
   signal WBpc_o				: std_logic_vector(PC_WIDTH-1 downto 0);
   signal IFinstruction_o		: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
   signal IDinstruction_o		: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
   signal EXinstruction_o		: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
   signal MEMinstruction_o		: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
   signal WBinstruction_o		: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
   signal STRIGGER_o			: std_logic;
   signal BPADDR_i				: std_logic_vector(7 downto 0);
   signal STCNT_o				: std_logic_vector(7 downto 0);
   signal FLCNT_o				: std_logic_vector(7 downto 0);
   SIGNAL mclk_cnt_tb_o			: STD_LOGIC_VECTOR(CLK_CNT_WIDTH-1 DOWNTO 0);
   SIGNAL inst_cnt_tb_o 		: STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0);
   
BEGIN
	CORE : MIPS
	generic map(
		WORD_GRANULARITY 			=> WORD_GRANULARITY,
	    MODELSIM 					=> MODELSIM,
		DATA_BUS_WIDTH				=> DATA_BUS_WIDTH,
		ITCM_ADDR_WIDTH				=> ITCM_ADDR_WIDTH,
		DTCM_ADDR_WIDTH				=> DTCM_ADDR_WIDTH,
		PC_WIDTH					=> PC_WIDTH,
		FUNCT_WIDTH					=> FUNCT_WIDTH,
		DATA_WORDS_NUM				=> DATA_WORDS_NUM,
		CLK_CNT_WIDTH				=> CLK_CNT_WIDTH,
		INST_CNT_WIDTH				=> INST_CNT_WIDTH
	)
	PORT MAP (
		rst_i           	=> rst_tb_i,
		clk_i           	=> clk_tb_i,
		BPADDR_i			=> BPADDR_i,
		STRIGGER_o			=> STRIGGER_o,
		IFpc_o				=> IFpc_o,
		IDpc_o				=> IDpc_o,
		EXpc_o				=> EXpc_o,
		MEMpc_o				=> MEMpc_o,
		WBpc_o				=> WBpc_o,
		IFinstruction_o		=> IFinstruction_o,
		IDinstruction_o		=> IDinstruction_o,
		EXinstruction_o		=> EXinstruction_o,
		MEMinstruction_o	=> MEMinstruction_o,
		WBinstruction_o		=> WBinstruction_o,
		STCNT_o				=> STCNT_o,
		FLCNT_o				=> FLCNT_o,
		mclk_cnt_o		   	=> mclk_cnt_tb_o,
		inst_cnt_o			=> inst_cnt_tb_o
	);

	BPADDR_i <= (others=>'0');	
--------------------------------------------------------------------	
	gen_clk : 
	process
        begin
		  clk_tb_i <= '1';
		  wait for 50 ns;
		  clk_tb_i <= not clk_tb_i;
		  wait for 50 ns;
    end process;
	
	gen_rst : 
	process
        begin
		  rst_tb_i <='1','0' after 80 ns;
		  wait;
    end process;
--------------------------------------------------------------------		
END struct;
