---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;
USE work.cond_comilation_package.all;
USE work.aux_package.all;


ENTITY MIPS IS
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
	PORT(	rst_i		 		:IN	STD_LOGIC;
			clk_i				:IN	STD_LOGIC; 
			-- break point signals
			BPADDR_i			:in		std_logic_vector(7 downto 0);
			STRIGGER_o				:out	std_logic;
			-- Output important signals to pins for easy display in SignalTap
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
END MIPS;
-------------------------------------------------------------------------------------
ARCHITECTURE structure OF MIPS IS
	-- declare signals used to connect VHDL components
	SIGNAL pc_plus4_w 		: STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
	SIGNAL read_data1_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL read_data2_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL sign_extend_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL addr_res_w 		: STD_LOGIC_VECTOR(7 DOWNTO 0 );
	SIGNAL alu_result_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL dtcm_data_rd_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	signal lui_value_w		: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL alu_src_w 		: STD_LOGIC;
	signal Usign_ctrl_w		: std_logic;
	SIGNAL branch_w 		: STD_LOGIC;
	SIGNAL branchN_w 		: STD_LOGIC;
	SIGNAL reg_dst_w 		: STD_LOGIC_vector(1 downto 0);
	SIGNAL reg_write_w 		: STD_LOGIC;
	SIGNAL zero_w 			: STD_LOGIC;
	SIGNAL neg_w 			: STD_LOGIC;
	SIGNAL mem_write_w 		: STD_LOGIC;
	SIGNAL MemtoReg_w 		: STD_LOGIC_vector(1 downto 0);
	SIGNAL mem_read_w 		: STD_LOGIC;
	SIGNAL JR_ctrl_w		: std_logic;
	SIGNAL Jump_ctrl_w		: std_logic;
	signal Jal_ctrl_w		: std_logic;
	signal if_flash_w		: std_logic;
	SIGNAL alu_op_w 		: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL instruction_w	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL MCLK_w 			: STD_LOGIC;
	SIGNAL mclk_cnt_q		: STD_LOGIC_VECTOR(CLK_CNT_WIDTH-1 DOWNTO 0);
	SIGNAL inst_cnt_w		: STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0);
	signal wb_addr_w		: std_logic_vector(4 downto 0);
	-- pipeline register signals
	-- forwarding mux signals
	signal r1_mux_w			: std_logic_vector(1 downto 0);
	signal r2_mux_w			: std_logic_vector(1 downto 0);
	signal write_reg_data_w	: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
	-- hazard detection unit signals
	signal hzrd_pc_en_w		: std_logic;
	signal if_id_en_w		: std_logic := '1';
	signal hzrd_halt_en_w	: std_logic;
	SIGNAL hzrd_alu_src_w 	: STD_LOGIC;
	signal hzrd_Usign_ctrl_w: std_logic;
	SIGNAL hzrd_branch_w 	: STD_LOGIC;
	SIGNAL hzrd_branchN_w 	: STD_LOGIC;
	SIGNAL hzrd_reg_dst_w 	: STD_LOGIC_vector(1 downto 0);
	SIGNAL hzrd_reg_write_w : STD_LOGIC;
	SIGNAL hzrd_mem_write_w : STD_LOGIC;
	SIGNAL hzrd_MemtoReg_w 	: STD_LOGIC_vector(1 downto 0);
	SIGNAL hzrd_mem_read_w 	: STD_LOGIC;
	SIGNAL hzrd_JR_ctrl_w	: std_logic;
	SIGNAL hzrd_Jump_ctrl_w	: std_logic;
	SIGNAL hzrd_alu_op_w 	: STD_LOGIC_VECTOR(1 DOWNTO 0);
	-- break point signals
	signal pc_en_w			: std_logic;
	signal halt_en_w		: std_logic;
	signal BP_en_w			: std_logic;
	signal cur_pc_w			: std_logic_vector(PC_WIDTH-1 downto 0);
	-- fetch-decode signals
	signal if_id_inst_w		: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
	signal if_id_pcp4_w		: std_logic_vector(PC_WIDTH-1 downto 0);
	-- decode - execute siganls
	signal id_ex_pcp4_w		: std_logic_vector(PC_WIDTH-1 downto 0);
	signal id_ex_r1_w		: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
	signal id_ex_r2_w		: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
	signal id_ex_signext_w	: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
	signal id_ex_r1_addr_w	: std_logic_vector(4 downto 0);
	signal id_ex_r2_addr_w	: std_logic_vector(4 downto 0);
	signal id_ex_inst_w		: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
	-- decode - execute control
	SIGNAL id_ex_alu_src_w 		: STD_LOGIC;
	signal id_ex_Usign_ctrl_w	: std_logic;
	SIGNAL id_ex_reg_dst_w 		: STD_LOGIC_vector(1 downto 0);
	SIGNAL id_ex_reg_write_w 	: STD_LOGIC;
	SIGNAL id_ex_mem_write_w 	: STD_LOGIC;
	SIGNAL id_ex_MemtoReg_w 	: STD_LOGIC_vector(1 downto 0);
	SIGNAL id_ex_mem_read_w 	: STD_LOGIC;
	SIGNAL id_ex_alu_op_w 		: STD_LOGIC_VECTOR(1 DOWNTO 0);
	-- execute - memory signals
	signal ex_mem_pcp4_w		: std_logic_vector(PC_WIDTH-1 downto 0);
	signal ex_mem_alu_res_w		: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
	signal ex_mem_wb_addr_w		: std_logic_vector(4 downto 0);
	signal ex_mem_r2_w			: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
	signal ex_mem_inst_w		: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
	-- execite - memory control
	SIGNAL ex_mem_reg_write_w 	: STD_LOGIC;
	SIGNAL ex_mem_mem_write_w 	: STD_LOGIC;
	SIGNAL ex_mem_MemtoReg_w 	: STD_LOGIC_vector(1 downto 0);
	SIGNAL ex_mem_mem_read_w 	: STD_LOGIC;
	-- memory - write-back signals
	signal mem_wb_pcp4_w		: std_logic_vector(PC_WIDTH-1 downto 0);
	signal mem_wb_alu_res_w		: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
	signal mem_wb_mem_data_w	: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
	signal mem_wb_wb_addr_w		: std_logic_vector(4 downto 0);
	signal mem_wb_inst_w		: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
	-- memory - write-back control
	SIGNAL mem_wb_reg_write_w 	: STD_LOGIC;
	SIGNAL mem_wb_MemtoReg_w 	: STD_LOGIC_vector(1 downto 0);

BEGIN
	-- output sigmals
	IFpc_o	<= cur_pc_w;
	IDpc_o 	<= if_id_pcp4_w;
	EXpc_o 	<= id_ex_pcp4_w;
	MEMpc_o <= ex_mem_pcp4_w;
	WBpc_o	<= mem_wb_pcp4_w;

	IFinstruction_o 	<= instruction_w;
	IDinstruction_o 	<= if_id_inst_w;
	EXinstruction_o 	<= id_ex_inst_w;
	MEMinstruction_o 	<= ex_mem_inst_w;
	WBinstruction_o		<= mem_wb_inst_w;

	-- hazard halt mux
	reg_dst_w		<= (others=>'0') when halt_en_w='1' else hzrd_reg_dst_w;
	alu_src_w		<= '0' when halt_en_w='1' else hzrd_alu_src_w;
	MemtoReg_w		<= (others=>'0') when halt_en_w='1' else hzrd_MemtoReg_w;
	reg_write_w		<= '0' when halt_en_w='1' else hzrd_reg_write_w;
	mem_read_w		<= '0' when halt_en_w='1' else hzrd_mem_read_w;
	mem_write_w		<= '0' when halt_en_w='1' else hzrd_mem_write_w;
	branch_w		<= '0' when halt_en_w='1' else hzrd_branch_w;
	branchN_w		<= '0' when halt_en_w='1' else hzrd_branchN_w;
	JR_ctrl_w		<= '0' when halt_en_w='1' else hzrd_JR_ctrl_w;
	Jump_ctrl_w		<= '0' when halt_en_w='1' else hzrd_Jump_ctrl_w;
	Usign_ctrl_w	<= '0' when halt_en_w='1' else hzrd_Usign_ctrl_w;
	alu_op_w		<= (others=>'0') when halt_en_w='1' else hzrd_alu_op_w;

	
	-- connect the PLL component
	G0:
	if (MODELSIM = 0) generate
	  MCLK: PLL
		PORT MAP (
			inclk0 	=> clk_i,
			c0 		=> MCLK_w
		);
	else generate
		MCLK_w <= clk_i;
	end generate;

	HZRD : hazard
	generic map (
		DATA_BUS_WIDTH		=> 	DATA_BUS_WIDTH
	)
	port map (
		clk_i 				=> MCLK_w,
		cur_inst_i			=> if_id_inst_w,
		prev_inst_i			=> id_ex_inst_w,
		prev_reg_dst_i		=> id_ex_reg_dst_w,
		pc_en_o				=> hzrd_pc_en_w,
		if_id_en_o			=> if_id_en_w,
		halt_en_o			=> hzrd_halt_en_w
	);

	FRWRD : forward
	generic map (
		DATA_BUS_WIDTH		=> 	DATA_BUS_WIDTH
	)
	port map (
		r1_addr_i			=> id_ex_r1_addr_w,
		r2_addr_i			=> id_ex_r2_addr_w,
		wb_addr_mem_i		=> ex_mem_wb_addr_w,
		wb_addr_wb_i		=> mem_wb_wb_addr_w,
		reg_wr_mem_i		=> ex_mem_reg_write_w,
		reg_wr_wb_i			=> mem_wb_reg_write_w,
		mem_read_i			=> ex_mem_mem_read_w,
		r1_mux_o			=> r1_mux_w,
		r2_mux_o			=> r2_mux_w
	);

	IFE : Ifetch
	generic map(
		WORD_GRANULARITY	=> 	WORD_GRANULARITY,
		DATA_BUS_WIDTH		=> 	DATA_BUS_WIDTH, 
		PC_WIDTH			=>	PC_WIDTH,
		ITCM_ADDR_WIDTH		=>	ITCM_ADDR_WIDTH,
		WORDS_NUM			=>	DATA_WORDS_NUM,
		INST_CNT_WIDTH		=>	INST_CNT_WIDTH
	)
	PORT MAP (	
		clk_i 			=> MCLK_w,  
		rst_i 			=> rst_i, 
		add_result_i 	=> addr_res_w,
		Branch_ctrl_i 	=> branch_w,
		BranchN_ctrl_i	=> branchN_w,
		Jump_ctrl_i		=> Jump_ctrl_w,
		JR_ctrl_i		=> JR_ctrl_w,
		zero_i 			=> zero_w,
		pc_en_i			=> pc_en_w,
		pc_o 			=> cur_pc_w,
		instruction_o 	=> instruction_w,
    	pc_plus4_o	 	=> pc_plus4_w,
		inst_cnt_o		=> inst_cnt_w
	);

	ID : Idecode
   	generic map(
		DATA_BUS_WIDTH		=>  DATA_BUS_WIDTH
	)
	PORT MAP (	
			clk_i 				=> MCLK_w,  
			rst_i 				=> rst_i,
        	instruction_i 		=> if_id_inst_w,
			old_inst_i			=> mem_wb_inst_w,
        	dtcm_data_rd_i 		=> mem_wb_mem_data_w,
			alu_result_i 		=> mem_wb_alu_res_w,
			RegWrite_ctrl_i 	=> mem_wb_reg_write_w,
			MemtoReg_ctrl_i 	=> mem_wb_MemtoReg_w,
			JR_ctrl_i			=> JR_ctrl_w,
			Jump_ctrl_i			=> Jump_ctrl_w,
			Jal_ctrl_i			=> Jal_ctrl_w,
			pc_plus_4_i			=> if_id_pcp4_w,
			write_reg_addr_i	=> mem_wb_wb_addr_w,
			zero_o 				=> zero_w,
			add_result_o		=> addr_res_w,
			read_data1_o 		=> read_data1_w,
        	read_data2_o 		=> read_data2_w,
			lui_value_o			=> lui_value_w,
			write_reg_data_o	=> write_reg_data_w,
			sign_extend_o 		=> sign_extend_w	 
		);

	CTL:   control
	PORT MAP ( 	
			opcode_i 			=> if_id_inst_w(DATA_BUS_WIDTH-1 DOWNTO 26),
			funct_i 			=> if_id_inst_w(5 DOWNTO 0),
			zero_i				=> zero_w,
			RegDst_ctrl_o 		=> hzrd_reg_dst_w,
			ALUSrc_ctrl_o 		=> hzrd_alu_src_w,
			MemtoReg_ctrl_o 	=> hzrd_MemtoReg_w,
			RegWrite_ctrl_o 	=> hzrd_reg_write_w,
			MemRead_ctrl_o 		=> hzrd_mem_read_w,
			MemWrite_ctrl_o 	=> hzrd_mem_write_w,
			Branch_ctrl_o 		=> hzrd_branch_w,
			BranchN_ctrl_o		=> hzrd_branchN_w,
			JR_ctrl_o			=> hzrd_JR_ctrl_w,
			Jump_ctrl_o			=> hzrd_Jump_ctrl_w,
			Jal_ctrl_o			=> Jal_ctrl_w,
			Usign_ctrl_o		=> hzrd_Usign_ctrl_w,
			if_flash_o			=> if_flash_w,
			ALUOp_ctrl_o 		=> hzrd_alu_op_w
		);

	EXE:  Execute
   	generic map(
		DATA_BUS_WIDTH 		=> 	DATA_BUS_WIDTH,
		FUNCT_WIDTH 		=>	FUNCT_WIDTH
	)
	PORT MAP (
		read_data1_i 	=> id_ex_r1_w,
        read_data2_i 	=> id_ex_r2_w,
		sign_extend_i 	=> id_ex_signext_w,
		instruction_i	=> id_ex_inst_w,
		RegDst_ctrl_i	=> id_ex_reg_dst_w,
        funct_i			=> id_ex_inst_w(5 DOWNTO 0),
		ALUOp_ctrl_i 	=> id_ex_alu_op_w,
		alu_res_wb_i	=> ex_mem_alu_res_w,
		wb_data_i		=> write_reg_data_w,
		r1_mux_i		=> r1_mux_w,
		r2_mux_i		=> r2_mux_w,
		ALUSrc_ctrl_i 	=> id_ex_alu_src_w,
		Usign_ctrl_i	=> id_ex_Usign_ctrl_w,
		opcode_i		=> id_ex_inst_w(31 downto 26),
		write_reg_addr_o=> wb_addr_w,
		neg_o			=> neg_w,
		-- zero_o 			=> zero_w,
        alu_res_o		=> alu_result_w	
	);

	G1: 
	if (WORD_GRANULARITY = True) generate -- i.e. each WORD has a unike address
		MEM:  dmemory
			generic map(
				DATA_BUS_WIDTH		=> 	DATA_BUS_WIDTH, 
				DTCM_ADDR_WIDTH		=> 	DTCM_ADDR_WIDTH,
				WORDS_NUM			=>	DATA_WORDS_NUM
			)
			PORT MAP (	
				clk_i 				=> MCLK_w,  
				rst_i 				=> rst_i,
				dtcm_addr_i 		=> ex_mem_alu_res_w((DTCM_ADDR_WIDTH+2)-1 DOWNTO 2), -- increment memory address by 4
				dtcm_data_wr_i 		=> ex_mem_r2_w,
				MemRead_ctrl_i 		=> ex_mem_mem_read_w, 
				MemWrite_ctrl_i 	=> ex_mem_mem_write_w,
				dtcm_data_rd_o 		=> dtcm_data_rd_w 
			);	
	elsif (WORD_GRANULARITY = False) generate -- i.e. each BYTE has a unike address	
		MEM:  dmemory
			generic map(
				DATA_BUS_WIDTH		=> 	DATA_BUS_WIDTH, 
				DTCM_ADDR_WIDTH		=> 	DTCM_ADDR_WIDTH,
				WORDS_NUM			=>	DATA_WORDS_NUM
			)
			PORT MAP (	
				clk_i 				=> MCLK_w,  
				rst_i 				=> rst_i,
				dtcm_addr_i 		=> ex_mem_alu_res_w(DTCM_ADDR_WIDTH-1 DOWNTO 2)&"00",
				dtcm_data_wr_i 		=> ex_mem_r2_w,
				MemRead_ctrl_i 		=> ex_mem_mem_read_w, 
				MemWrite_ctrl_i 	=> ex_mem_mem_write_w,
				dtcm_data_rd_o 		=> dtcm_data_rd_w
			);
	end generate;
---------------------------------------------------------------------------------------
--									IPC - MCLK counter register
---------------------------------------------------------------------------------------
process (MCLK_w , rst_i)
begin
	if rst_i = '1' then
		mclk_cnt_q	<=	(others	=> '0');
	elsif (rising_edge(MCLK_w) AND BP_en_w='0') then
		mclk_cnt_q	<=	mclk_cnt_q + '1';
	end if;
end process;

mclk_cnt_o	<=	mclk_cnt_q;
inst_cnt_o	<=	inst_cnt_w;
---------------------------------------------------------------------------------------
--									Pipeline registers
---------------------------------------------------------------------------------------
-- fetch decode register
process (clk_i, if_flash_w)
begin
	
	if rising_edge(clk_i) then
		if (if_id_en_w='1' and BP_en_w='0') then
			if (if_flash_w = '1') then
				if_id_inst_w <= (others=>'0');
				if_id_pcp4_w <= (others=>'0');
			else
				if_id_inst_w <= instruction_w;
				if_id_pcp4_w <= pc_plus4_w;
			end if;
		end if;
	end if;
end process;
-- decocde execute register
process (clk_i)
begin
	-- if rst_i = '1' then
	-- 	-- decode - execute siganls
	-- 	id_ex_pcp4_w		<= (others=>'0');
	-- 	id_ex_r1_w			<= (others=>'0');
	-- 	id_ex_r2_w			<= (others=>'0');
	-- 	id_ex_signext_w		<= (others=>'0');
	-- 	id_ex_r1_addr_w		<= (others=>'0');
	-- 	id_ex_r2_addr_w		<= (others=>'0');
	-- 	id_ex_r3_addr_w		<= (others=>'0');
	-- 	id_ex_inst_w		<= (others=>'0');
	-- 	-- decode - execute control
	-- 	id_ex_alu_src_w		<= '0';
	-- 	id_ex_Usign_ctrl_w	<= '0';
	-- 	id_ex_reg_dst_w		<= (others=>'0');
	-- 	id_ex_reg_write_w	<= '0';
	-- 	id_ex_mem_write_w	<= '0';
	-- 	id_ex_MemtoReg_w	<= (others=>'0');
	-- 	id_ex_mem_read_w	<= '0';
	-- 	id_ex_alu_op_w		<= (others=>'0');
	if (rising_edge(clk_i) and BP_en_w='0') then
		-- decode - execute siganls
		id_ex_pcp4_w		<= if_id_pcp4_w;
		id_ex_r1_w			<= read_data1_w;
		id_ex_r2_w			<= read_data2_w;
		id_ex_signext_w		<= sign_extend_w;
		id_ex_r1_addr_w		<= if_id_inst_w(25 downto 21);
		id_ex_r2_addr_w		<= if_id_inst_w(20 downto 16);
		id_ex_inst_w		<= if_id_inst_w;
		-- decode - execute control
		id_ex_alu_src_w		<= alu_src_w;
		id_ex_Usign_ctrl_w	<= Usign_ctrl_w;
		id_ex_reg_dst_w		<= reg_dst_w;
		id_ex_reg_write_w	<= reg_write_w;
		id_ex_mem_write_w	<= mem_write_w;
		id_ex_MemtoReg_w	<= MemtoReg_w;
		id_ex_mem_read_w	<= mem_read_w;
		id_ex_alu_op_w		<= alu_op_w;
	end if;
end process;
-- execute memory register
process (clk_i)
begin
	-- if rst_i = '1' then
	-- 	-- execute - memory signals
	-- 	ex_mem_pcp4_w		<= (others=>'0');
	-- 	ex_mem_alu_res_w	<= (others=>'0');
	-- 	ex_mem_wb_addr_w	<= (others=>'0');
	-- 	ex_mem_r2_w			<= (others=>'0');
	-- 	ex_mem_inst_w		<= (others=>'0');
	-- 	-- execite - memory control
	-- 	ex_mem_reg_write_w	<= '0';
	-- 	ex_mem_mem_write_w	<= '0';
	-- 	ex_mem_MemtoReg_w	<= (others=>'0');
	-- 	ex_mem_mem_read_w	<= '0';
	if (rising_edge(clk_i) and BP_en_w='0') then
		-- execute - memory signals
		ex_mem_pcp4_w		<= id_ex_pcp4_w;
		ex_mem_alu_res_w	<= alu_result_w;
		ex_mem_wb_addr_w	<= wb_addr_w;
		ex_mem_r2_w			<= id_ex_r2_w;
		ex_mem_inst_w		<= id_ex_inst_w;
		-- execite - memory control
		ex_mem_reg_write_w	<= id_ex_reg_write_w;
		ex_mem_mem_write_w	<= id_ex_mem_write_w;
		ex_mem_MemtoReg_w	<= id_ex_MemtoReg_w;
		ex_mem_mem_read_w	<= id_ex_mem_read_w;
	end if;
end process;
-- memory write-back register
process (clk_i)
begin
	-- if rst_i = '1' then
	-- 	-- memory - write-back signals
	-- 	mem_wb_pcp4_w		<= (others=>'0');
	-- 	mem_wb_alu_res_w	<= (others=>'0');
	-- 	mem_wb_mem_data_w	<= (others=>'0');
	-- 	mem_wb_wb_addr_w	<= (others=>'0');
	-- 	mem_wb_inst_w		<= (others=>'0');
	-- 	-- memory - write-back control
	-- 	mem_wb_reg_write_w	<= '0';
	-- 	mem_wb_MemtoReg_w	<= (others=>'0');
	if (rising_edge(clk_i) and BP_en_w='0') then
		-- memory - write-back signals
		mem_wb_inst_w		<= ex_mem_inst_w;
		mem_wb_pcp4_w		<= ex_mem_pcp4_w;
		mem_wb_alu_res_w	<= ex_mem_alu_res_w;
		mem_wb_mem_data_w	<= dtcm_data_rd_w;
		mem_wb_wb_addr_w    <= ex_mem_wb_addr_w;
		-- memory - write-back control
		mem_wb_reg_write_w	<= ex_mem_reg_write_w;
		mem_wb_MemtoReg_w	<= ex_mem_MemtoReg_w;
	end if;
end process;
---------------------------------------------------------------------------------------
--									Outout registers + BP
---------------------------------------------------------------------------------------
-- ouput register -> stall and flash count
process (clk_i, rst_i)
begin
	if (rst_i='1') then
		STCNT_o <= (others=>'0');
		FLCNT_o <= (others=>'0');
	elsif (rising_edge(clk_i) and BP_en_w='0') then
		if (halt_en_w='1') then
			STCNT_o <= STCNT_o + '1';
		elsif (if_flash_w='1') then
			FLCNT_o <= FLCNT_o + '1';
		end if;
	end if;
end process;
-- break point logic
BP_en_w <= '1' when (cur_pc_w(9 downto 2)=BPADDR_i and BPADDR_i/=X"00") else '0';
STRIGGER_o <= BP_en_w;
pc_en_w <= hzrd_pc_en_w and not BP_en_w;
halt_en_w <= hzrd_halt_en_w;-- or BP_en_w;
---------------------------------------------------------------------------------------
END structure;

