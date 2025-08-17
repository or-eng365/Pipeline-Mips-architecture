onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /mips_tb/rst_tb_i
add wave -noupdate -radix hexadecimal /mips_tb/clk_tb_i
add wave -noupdate -radix hexadecimal /mips_tb/IFpc_o
add wave -noupdate -radix hexadecimal /mips_tb/IDpc_o
add wave -noupdate -radix hexadecimal /mips_tb/EXpc_o
add wave -noupdate -radix hexadecimal /mips_tb/MEMpc_o
add wave -noupdate -radix hexadecimal /mips_tb/WBpc_o
add wave -noupdate -radix hexadecimal /mips_tb/IFinstruction_o
add wave -noupdate -radix hexadecimal /mips_tb/IDinstruction_o
add wave -noupdate -radix hexadecimal /mips_tb/EXinstruction_o
add wave -noupdate -radix hexadecimal /mips_tb/MEMinstruction_o
add wave -noupdate -radix hexadecimal /mips_tb/WBinstruction_o
add wave -noupdate -radix hexadecimal /mips_tb/STRIGGER_o
add wave -noupdate -radix hexadecimal /mips_tb/BPADDR_i
add wave -noupdate -radix hexadecimal /mips_tb/STCNT_o
add wave -noupdate -radix hexadecimal /mips_tb/FLCNT_o
add wave -noupdate -radix hexadecimal /mips_tb/mclk_cnt_tb_o
add wave -noupdate -radix hexadecimal /mips_tb/inst_cnt_tb_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {82878 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {512 ns}
