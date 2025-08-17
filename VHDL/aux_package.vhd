---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
USE work.cond_comilation_package.all;


package aux_package is

	component MIPS is
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
		PORT(	
			rst_i		 		:IN	STD_LOGIC;
			clk_i				:IN	STD_LOGIC; 
			-- break point signals
			BPADDR_i			:in		std_logic_vector(7 downto 0);
			STRIGGER_o				:out	std_logic;
			-- Output important signals to pins for easy display in Simulator
			IFpc_o				:out	std_logic_vector(PC_WIDTH-1 downto 0);
			IDpc_o				:out	std_logic_vector(PC_WIDTH-1 downto 0);
			EXpc_o				:out	std_logic_vector(PC_WIDTH-1 downto 0);
			MEMpc_o				:out	std_logic_vector(PC_WIDTH-1 downto 0);
			WBpc_o				:out	std_logic_vector(PC_WIDTH-1 downto 0);
			IFinstruction_o		:out	std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			IDinstruction_o		:out	std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			EXinstruction_o		:out	std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			MEMinstruction_o		:out	std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			WBinstruction_o		:out	std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			STCNT_o				:out	std_logic_vector(7 downto 0);
			FLCNT_o				:out	std_logic_vector(7 downto 0);
			mclk_cnt_o			:OUT	STD_LOGIC_VECTOR(CLK_CNT_WIDTH-1 DOWNTO 0);
			inst_cnt_o 			:OUT	STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0)
		);		
	end component;
---------------------------------------------------------  
	component control is
		PORT( 	
		opcode_i 			: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
		funct_i 			: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
		zero_i				: in 	std_logic;
		RegDst_ctrl_o 		: OUT 	STD_LOGIC_vector(1 downto 0);
		ALUSrc_ctrl_o 		: OUT 	STD_LOGIC;
		MemtoReg_ctrl_o 	: OUT 	STD_LOGIC_vector(1 downto 0);
		RegWrite_ctrl_o 	: OUT 	STD_LOGIC;
		MemRead_ctrl_o 		: OUT 	STD_LOGIC;
		MemWrite_ctrl_o	 	: OUT 	STD_LOGIC;
		Branch_ctrl_o 		: OUT 	STD_LOGIC;
		BranchN_ctrl_o 		: OUT 	STD_LOGIC;
		JR_ctrl_o			: OUT	std_logic;
		Jump_ctrl_o			: OUT	std_logic;
		Jal_ctrl_o			: out	std_logic;
		Usign_ctrl_o		: OUT	std_logic;
		if_flash_o			: out	std_logic;
		ALUOp_ctrl_o	 	: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
	end component;
---------------------------------------------------------	
	component dmemory is
		generic(
		DATA_BUS_WIDTH : integer := 32;
		DTCM_ADDR_WIDTH : integer := 8;
		WORDS_NUM : integer := 256
	);
	PORT(	clk_i,rst_i			: IN 	STD_LOGIC;
			dtcm_addr_i 		: IN 	STD_LOGIC_VECTOR(DTCM_ADDR_WIDTH-1 DOWNTO 0);
			dtcm_data_wr_i 		: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			MemRead_ctrl_i  	: IN 	STD_LOGIC;
			MemWrite_ctrl_i 	: IN 	STD_LOGIC;
			dtcm_data_rd_o 		: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
	);
	end component;
---------------------------------------------------------		
	component Execute is
		generic(
			DATA_BUS_WIDTH : integer := 32;
			FUNCT_WIDTH : integer := 6
		);
		PORT(	
			read_data1_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data2_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			sign_extend_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			instruction_i	: in 	std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			RegDst_ctrl_i 	: IN 	STD_LOGIC_vector(1 downto 0);
			funct_i 		: IN 	STD_LOGIC_VECTOR(FUNCT_WIDTH-1 DOWNTO 0);
			ALUOp_ctrl_i 	: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);
			ALU_res_wb_i	: in 	std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			wb_data_i		: in 	std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			r1_mux_i		: in 	std_logic_vector(1 downto 0);
			r2_mux_i		: in 	std_logic_vector(1 downto 0);
			ALUSrc_ctrl_i 	: IN 	STD_LOGIC;
			Usign_ctrl_i	: in 	std_logic;
			opcode_i		: in	std_logic_vector(5 downto 0);
			write_reg_addr_o: out	std_logic_vector(4 downto 0);
			neg_o			: out	std_logic;
			-- zero_o 			: OUT	STD_LOGIC;
			alu_res_o 		: OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
		);
	end component;
---------------------------------------------------------		
	component Idecode is
		generic(
			DATA_BUS_WIDTH : integer := 32;
			PC_WIDTH : integer 		 := 10
		);
		PORT(	
			clk_i,rst_i		: IN 	STD_LOGIC;
			instruction_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			old_inst_i 		: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			dtcm_data_rd_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			alu_result_i	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			RegWrite_ctrl_i : IN 	STD_LOGIC;
			MemtoReg_ctrl_i : IN 	STD_LOGIC_vector(1 downto 0);
			JR_ctrl_i		: in	std_logic;
			Jump_ctrl_i		: in 	std_logic;
			Jal_ctrl_i		: in 	std_logic;
			pc_plus_4_i		: in	std_logic_vector(PC_WIDTH-1 downto 0);
			write_reg_addr_i: in	std_logic_vector(4 downto 0);
			zero_o			: out	std_logic;
			add_result_o	: out 	std_logic_vector(7 downto 0);
			read_data1_o	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data2_o	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			lui_value_o		: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			write_reg_data_o: out	std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			sign_extend_o 	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)		 
		);
	end component;
---------------------------------------------------------		
	component Ifetch is
		generic(
			WORD_GRANULARITY : boolean 	:= False;
			DATA_BUS_WIDTH : integer 	:= 32;
			PC_WIDTH : integer 			:= 10;
			NEXT_PC_WIDTH : integer 	:= 8; -- NEXT_PC_WIDTH = PC_WIDTH-2
			ITCM_ADDR_WIDTH : integer 	:= 8;
			WORDS_NUM : integer 		:= 256;
			INST_CNT_WIDTH : integer 	:= 16
		);
		PORT(	
			clk_i, rst_i 	: IN 	STD_LOGIC;
			add_result_i 	: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
        	Branch_ctrl_i 	: IN 	STD_LOGIC;
			BranchN_ctrl_i 	: IN 	STD_LOGIC;
			Jump_ctrl_i		: in 	std_logic;
			JR_ctrl_i		: in	std_logic;
        	zero_i 			: IN 	STD_LOGIC;
			pc_en_i			: in	std_logic;
			pc_o 			: OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			pc_plus4_o 		: OUT	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			instruction_o 	: OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			inst_cnt_o 		: OUT	STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0)	
		);
	end component;
---------------------------------------------------------
	COMPONENT PLL port(
	    areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0     		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC );
    END COMPONENT;
---------------------------------------------------------	
	component Shifter IS
		GENERIC (n : INTEGER := 8);
		PORT (   ALUFN: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
				x: in std_logic_vector(4 downto 0);
				y: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
				cout: OUT STD_LOGIC;
				ALUout: OUT STD_LOGIC_VECTOR(n-1 downto 0));

	end component;
---------------------------------------------------------
	component forward is
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
	end component;
---------------------------------------------------------
	component hazard is
		generic(
			DATA_BUS_WIDTH : integer := 32
		);
		PORT( 	
			clk_i           : in    std_logic;
			cur_inst_i      : in    std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			prev_inst_i     : in    std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			prev_reg_dst_i  : in    std_logic_vector(1 downto 0);
			pc_en_o         : out   std_logic;
			if_id_en_o      : out   std_logic;
			halt_en_o       : out   std_logic
		);
	end component;
---------------------------------------------------------
end aux_package;

