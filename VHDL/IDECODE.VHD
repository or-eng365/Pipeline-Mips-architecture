---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
--  Idecode module (implements the register file for the MIPS computer
LIBRARY IEEE; 		
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY Idecode IS
	generic(
		DATA_BUS_WIDTH : integer := 32;
		PC_WIDTH : integer 		 := 10
	);
	PORT(	clk_i,rst_i		: IN 	STD_LOGIC;
			instruction_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			old_inst_i 		: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			dtcm_data_rd_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			alu_result_i	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			RegWrite_ctrl_i : IN 	STD_LOGIC;
			MemtoReg_ctrl_i : IN 	std_logic_vector(1 downto 0);
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
END Idecode;


ARCHITECTURE behavior OF Idecode IS
TYPE register_file IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);

	SIGNAL RF_q					: register_file;
	SIGNAL write_reg_data_w		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	signal write_reg_mux_w		: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
	signal write_reg_addr_w		: std_logic_vector(4 downto 0);
	signal write_reg_en_w		: std_logic;
	SIGNAL rs_register_w		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL rt_register_w		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL imm_value_w			: STD_LOGIC_VECTOR( 15 DOWNTO 0 );
	SIGNAL lui_value_w			: std_logic_vector( 31 downto 0 );
	SIGNAL branch_addr_r 		: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL zero_vec_w			: std_logic_vector ( DATA_BUS_WIDTH-1 downto PC_WIDTH) := (others=>'0');
	SIGNAL zero_vec2_w			: std_logic_vector ( 16-1 downto 0) := (others=>'0');

BEGIN
	rs_register_w 			<= instruction_i(25 DOWNTO 21);
   	rt_register_w 			<= instruction_i(20 DOWNTO 16);
   	imm_value_w 			<= instruction_i(15 DOWNTO 0);	

	-- Read Register 1 Operation
	read_data1_o <= RF_q(CONV_INTEGER(rs_register_w));
	
	-- Read Register 2 Operation		 
	read_data2_o <= (OTHERS=>'0') WHEN JR_ctrl_i else RF_q(CONV_INTEGER(rt_register_w));

	-- read1 = read2
	zero_o <= '1' when (read_data1_o=read_data2_o) else '0';
	
	-- Mux for Register Write Address

	lui_value_w <= old_inst_i(15 downto 0) & zero_vec2_w;
	lui_value_o <= lui_value_w;

	-- jump decision mux
	-- Adder to compute Branch Address --> move to decode!
	branch_addr_r	<= pc_plus_4_i(PC_WIDTH-1 DOWNTO 2) + imm_value_w(7 downto 0);

	add_result_o <= instruction_i(7 downto 0) when Jump_ctrl_i else
					read_data1_o(PC_WIDTH-1 downto 2) when JR_ctrl_i else
					branch_addr_r;

	write_reg_addr_w <= "11111" when Jal_ctrl_i else write_reg_addr_i;
	write_reg_en_w <= '1' when Jal_ctrl_i else RegWrite_ctrl_i;
	
	-- Mux to bypass data memory for Rformat instructions
	-- write_reg_data_w <= alu_result_i(DATA_BUS_WIDTH-1 DOWNTO 0) WHEN (MemtoReg_ctrl_i = '0') ELSE 
	-- 					dtcm_data_rd_i;
	reg_data_mux: with MemtoReg_ctrl_i select
		write_reg_mux_w <= alu_result_i(DATA_BUS_WIDTH-1 downto 0) when "00",
							dtcm_data_rd_i when "01",
							lui_value_w when "10",
							--zero_vec_w & pc_plus_4_i when "11",
							(others=>'0') when others;
	write_reg_data_w <= zero_vec_w & pc_plus_4_i when  Jal_ctrl_i else write_reg_mux_w;
	write_reg_data_o <= write_reg_data_w;
	
	-- Sign Extend 16-bits to 32-bits
    sign_extend_o <= 	X"0000" & imm_value_w WHEN imm_value_w(15) = '0' ELSE
						X"FFFF" & imm_value_w;


	process(clk_i,rst_i)
	begin
		if (rst_i='1') then
			FOR i IN 0 TO 31 LOOP
				-- RF_q(i) <= CONV_STD_LOGIC_VECTOR(i,32);
				RF_q(i) <= CONV_STD_LOGIC_VECTOR(0,32);
			END LOOP;
		elsif (clk_i'event and clk_i='0') then
			if (write_reg_en_w = '1' AND write_reg_addr_w /= 0) then
				RF_q(CONV_INTEGER(write_reg_addr_w)) <= write_reg_data_w;
				-- index is integer type so we must use conv_integer for type casting
			end if;
		end if;
end process;

END behavior;





