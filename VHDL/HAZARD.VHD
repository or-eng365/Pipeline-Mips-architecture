LIBRARY IEEE; 		
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.aux_package.all;
USE work.const_package.all;

ENTITY hazard IS
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
END hazard;

architecture hazard_arch of hazard is
    signal clk_count_w                      : std_logic_vector(1 downto 0) := "00";
    signal start_halt_br_w, stop_halt_br_w  : boolean;
    signal halt_for_lw_w                    : boolean;
    signal cur_op_br_w                      : boolean;
    signal cur_op_lw_w                      : boolean;
    signal prev_op_lw_w                     : boolean;
    signal reg_dependency_w                 : boolean;
    signal no_halt_b_w                      : boolean;
    signal no_halt_w                        : std_logic;
    signal reg_depend_w                     : std_logic_vector(4 downto 0);
    signal cur_rs_w, cur_rt_w, cur_rd_w     : std_logic_vector(4 downto 0);
    signal prev_rt_w, prev_rd_w             : std_logic_vector(4 downto 0);
    signal prev_op_w, cur_op_w              : std_logic_vector(5 downto 0);
    signal cur_func_w                       : std_logic_vector(5 downto 0);
begin
    -- clock counter
    clk_cnt: process(clk_i)
    begin
        if rising_edge(clk_i) then
            if (stop_halt_br_w or (halt_for_lw_w and clk_count_w="01") or (no_halt_w='1')) then
                clk_count_w <= "00";
            elsif (no_halt_w='0') then
                clk_count_w <= clk_count_w+'1';
            end if;
        end if;
    end process;

    -- clock counter initialize
    -- clk_count_w <= "00" when (halt_for_br_w and clk_count_w="11") or (halt_for_lw_w and clk_count_w="01") or (no_halt_w='1');

    -- internal control logic
    -- boolean values for halt detection:
    prev_op_lw_w <= prev_op_w=LW_OPC or prev_op_w=LUI_OPC;
    cur_op_lw_w <= cur_op_w=LW_OPC or cur_op_w=LUI_OPC;
    cur_op_br_w <= cur_op_w=BEQ_OPC or cur_op_w=BNEQ_OPC or cur_op_w=SW_OPC or (cur_func_w=JR_OPC and cur_op_w=R_TYPE_OPC);
    reg_dependency_w <= ((cur_rs_w=reg_depend_w) or 
                        (cur_rt_w=reg_depend_w and (cur_op_w=R_TYPE_OPC or cur_op_w=MUL_OPC)) or 
                        (cur_rt_w=reg_depend_w and (cur_op_w=BEQ_OPC or cur_op_w=BNEQ_OPC or cur_op_w=SW_OPC))) and (reg_depend_w/="00000");
    no_halt_b_w <= stop_halt_br_w or (halt_for_lw_w and clk_count_w="01") or (not (cur_op_br_w or halt_for_lw_w));
    -- halt decision variables:
    halt_for_lw_w <= (prev_op_lw_w and reg_dependency_w) or cur_op_lw_w;-- and reg_dependency_w;
    start_halt_br_w <= cur_op_br_w and reg_dependency_w;
    stop_halt_br_w <= cur_op_br_w and clk_count_w="11";
    -- clock counter enable '0'->on '1'->off
    no_halt_w <= '1' when no_halt_b_w else
                '0' when start_halt_br_w or halt_for_lw_w;

    -- register dependency
    reg_depend_w <= prev_rd_w WHEN prev_reg_dst_i = "01" ELSE 
						"11111"	when prev_reg_dst_i = "10" ELSE
						prev_rt_w;

    -- data extraction
    -- current instruction:
    cur_op_w <= cur_inst_i(31 downto 26);
    cur_func_w <= cur_inst_i(5 downto 0);
    cur_rs_w <= cur_inst_i(25 downto 21);
    cur_rt_w <= cur_inst_i(20 downto 16);
    cur_rd_w <= cur_inst_i(15 downto 11);
    -- previous instruciton:
    prev_op_w <= prev_inst_i(31 downto 26);
    prev_rt_w <= prev_inst_i(20 downto 16);
    prev_rd_w <= prev_inst_i(15 downto 11);

    -- enable logic
    pc_en_o <= '1' when no_halt_w else '0';
    if_id_en_o <= '1' when no_halt_w else '0';
    halt_en_o <= '0' when no_halt_w else '1';
end architecture;