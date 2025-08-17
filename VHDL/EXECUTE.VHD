---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
use ieee.numeric_std.all;
USE work.const_package.all;
USE work.aux_package.all;


ENTITY  Execute IS
	generic(
		DATA_BUS_WIDTH : integer := 32;
		FUNCT_WIDTH : integer := 6
	);
	PORT(	read_data1_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data2_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			sign_extend_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			instruction_i	: in 	std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			RegDst_ctrl_i 	: IN 	STD_LOGIC_vector(1 downto 0);
			funct_i 		: IN 	STD_LOGIC_VECTOR(FUNCT_WIDTH-1 DOWNTO 0); -- opcode: instruction (5 downto 0 )
			ALUOp_ctrl_i 	: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);
			ALU_res_wb_i	: in 	std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			wb_data_i		: in 	std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			r1_mux_i		: in 	std_logic_vector(1 downto 0);
			r2_mux_i		: in 	std_logic_vector(1 downto 0);
			ALUSrc_ctrl_i 	: IN 	STD_LOGIC;
			Usign_ctrl_i	: in 	std_logic;
			opcode_i		: IN 	std_logic_vector (5 downto 0);
			write_reg_addr_o: out	std_logic_vector(4 downto 0);
			neg_o			: out	std_logic;
			-- zero_o 			: OUT	STD_LOGIC;
			alu_res_o 		: OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
	);
END Execute;


ARCHITECTURE behavior OF Execute IS
SIGNAL a_input_w, b_input_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
SIGNAL a_mux_w, b_mux_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
SIGNAL alu_out_mux_w			: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
SIGNAL shift_out_w				: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
SIGNAL alu_ctl_w				: STD_LOGIC_VECTOR(2 DOWNTO 0);
signal shamt_w					: std_logic_vector(4 downto 0);
signal a_mul_w, b_mul_w			: ieee.numeric_std.UNSIGNED(15 downto 0);
signal rd_register_w 			: std_logic_vector(4 downto 0);
signal rt_register_w			: std_logic_vector(4 downto 0);
BEGIN
	-- shifter value definition
	shamt_w <= instruction_i(10 downto 6);

	-- pipeline mux inputs
	with r1_mux_i select
		a_mux_w	<=	ALU_res_wb_i when "01",
					wb_data_i	 when "10",
					read_data1_i when others;

	with r2_mux_i select
		b_mux_w	<=	ALU_res_wb_i when "01",
					wb_data_i	 when "10",
					read_data2_i when others;

	a_input_w <= 	std_logic_vector(ieee.numeric_std.unsigned(a_mux_w)) when Usign_ctrl_i else a_mux_w;
	-- ALU input mux
	b_input_w <= 	b_mux_w WHEN (ALUSrc_ctrl_i = '0') ELSE
					std_logic_vector(ieee.numeric_std.unsigned(b_mux_w)) when (Usign_ctrl_i='1' and (ALUSrc_ctrl_i = '0')) else
					std_logic_vector(ieee.numeric_std.unsigned(sign_extend_i(DATA_BUS_WIDTH-1 DOWNTO 0))) when Usign_ctrl_i='1' else
					sign_extend_i(DATA_BUS_WIDTH-1 DOWNTO 0);

	a_mul_w <= ieee.numeric_std.unsigned(a_input_w(15 downto 0));
	b_mul_w <= ieee.numeric_std.unsigned(b_input_w(15 downto 0));

	rt_register_w 			<= instruction_i(20 DOWNTO 16);
   	rd_register_w			<= instruction_i(15 DOWNTO 11);
	write_reg_addr_o <= rd_register_w WHEN RegDst_ctrl_i = "01" ELSE 
						--"11111"	when RegDst_ctrl_i = "10" ELSE
						rt_register_w;
--------------------------------------------------------------------------------------------------------
--  Generate ALU control bits
--------------------------------------------------------------------------------------------------------
	-- add -> 000
	-- sub -> 010
	-- and -> 100
	-- or  -> 101
	-- xor -> 110
	-- sll -> 001
	-- srl -> 011
	-- mul -> 111

	alu_ctl_w(0) <= '1' when ((ALUOp_ctrl_i="10" and ((funct_i(0)='1' and funct_i(2)='1') or (funct_i(5)='0'))) or (ALUOp_ctrl_i="11" and (opcode_i(0)='1' and opcode_i(2)='1')) or (opcode_i(4)='1')) else '0';
	alu_ctl_w(1) <= '1' when ((ALUOp_ctrl_i="10" and funct_i(1)='1') or (ALUOp_ctrl_i="11" and opcode_i(1)='1') or (opcode_i(4)='1') or (ALUOp_ctrl_i="01")) else '0';
	alu_ctl_w(2) <= '1' when ((ALUOp_ctrl_i="10" and funct_i(2)='1') or (ALUOp_ctrl_i="11" and opcode_i(2)='1') or (opcode_i(4)='1')) else '0';
--------------------------------------------------------------------------------------------------------
	
	-- -- Generate Zero Flag
	-- zero_o <= 	'1' WHEN (alu_out_mux_w(DATA_BUS_WIDTH-1 DOWNTO 0) = X"00000000") ELSE
	-- 			'0';    

	-- Generate Negative Flag
	neg_o <=	alu_out_mux_w(DATA_BUS_WIDTH-1);
	
	-- Select ALU output        
	alu_res_o <= 	X"0000000" & B"000"  & alu_out_mux_w(31) WHEN  ((ALUOp_ctrl_i="10" and funct_i="101010") or (ALUOp_ctrl_i="11" and opcode_i="001010")) ELSE 
					alu_out_mux_w(DATA_BUS_WIDTH-1 DOWNTO 0);

	shift: Shifter generic map(n=>DATA_BUS_WIDTH) port map (
		ALUFN => alu_ctl_w,
		x => shamt_w, -- needs to be shamt
		y => a_input_w,
		ALUout => shift_out_w
	);

PROCESS (alu_ctl_w, a_input_w, b_input_w, a_mul_w, b_mul_w)
	BEGIN		
 	CASE alu_ctl_w IS	-- Select ALU operation
						-- ALU performs ALUresult = A_input + B_input
		WHEN "000" 	=>	alu_out_mux_w 	<= a_input_w + b_input_w; 
						-- ALU performs ALUresult = shift left
     	WHEN "001" 	=>	alu_out_mux_w 	<= shift_out_w;
						-- ALU performs ALUresult = A_input - B_input
	 	WHEN "010" 	=>	alu_out_mux_w 	<= a_input_w - b_input_w;
						-- ALU performs ALUresult = shift right
 	 	WHEN "011" 	=>	alu_out_mux_w 	<= shift_out_w;
						-- ALU performs  ALUresult = A_input and B_input
 	 	WHEN "100" 	=>	alu_out_mux_w 	<= a_input_w and b_input_w;
						-- ALU performs ALUresult = A_input or B_input
 	 	WHEN "101" 	=>	alu_out_mux_w 	<= a_input_w or b_input_w;
						-- ALU performs ALUresult = A_input xor B_input
 	 	WHEN "110" 	=>	alu_out_mux_w 	<= a_input_w xor b_input_w;
						-- ALU performs ALUresult = A_input * B_input
  	 	WHEN "111" 	=>	alu_out_mux_w 	<= std_logic_vector(a_mul_w * b_mul_w) ;
 	 	WHEN OTHERS	=>	alu_out_mux_w 	<= X"00000000" ;
  	END CASE;
  END PROCESS;
  
END behavior;

