onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {Global Signals} -color Cyan -label Clock /Simulate_this_for_Run_tests/clk
add wave -noupdate -expand -group {Global Signals} -color Cyan -label Reset /Simulate_this_for_Run_tests/reset
add wave -noupdate -expand -group Port1 -color Orange /Simulate_this_for_Run_tests/req1_tag_in
add wave -noupdate -expand -group Port1 -color {Lime Green} -radix binary /Simulate_this_for_Run_tests/req1_cmd_in
add wave -noupdate -expand -group Port1 -color {Lime Green} /Simulate_this_for_Run_tests/req1_data_in
add wave -noupdate -expand -group Port1 -color Gold /Simulate_this_for_Run_tests/out_tag1
add wave -noupdate -expand -group Port1 -color Gold /Simulate_this_for_Run_tests/out_resp1
add wave -noupdate -expand -group Port1 -color Gold /Simulate_this_for_Run_tests/out_data1
add wave -noupdate -group Port2 -color Orange /Simulate_this_for_Run_tests/req2_tag_in
add wave -noupdate -group Port2 -color {Lime Green} -radix binary /Simulate_this_for_Run_tests/req2_cmd_in
add wave -noupdate -group Port2 -color {Lime Green} /Simulate_this_for_Run_tests/req2_data_in
add wave -noupdate -group Port2 -color Gold /Simulate_this_for_Run_tests/out_tag2
add wave -noupdate -group Port2 -color Gold /Simulate_this_for_Run_tests/out_resp2
add wave -noupdate -group Port2 -color Gold /Simulate_this_for_Run_tests/out_data2
add wave -noupdate -group Port3 -color Orange /Simulate_this_for_Run_tests/req3_tag_in
add wave -noupdate -group Port3 -color {Lime Green} -radix binary /Simulate_this_for_Run_tests/req3_cmd_in
add wave -noupdate -group Port3 -color {Lime Green} /Simulate_this_for_Run_tests/req3_data_in
add wave -noupdate -group Port3 -color Gold /Simulate_this_for_Run_tests/out_tag3
add wave -noupdate -group Port3 -color Gold /Simulate_this_for_Run_tests/out_resp3
add wave -noupdate -group Port3 -color Gold /Simulate_this_for_Run_tests/out_data3
add wave -noupdate -group Port4 -color Orange /Simulate_this_for_Run_tests/req4_tag_in
add wave -noupdate -group Port4 -color {Lime Green} -radix binary /Simulate_this_for_Run_tests/req4_cmd_in
add wave -noupdate -group Port4 -color {Lime Green} /Simulate_this_for_Run_tests/req4_data_in
add wave -noupdate -group Port4 -color Gold /Simulate_this_for_Run_tests/out_tag4
add wave -noupdate -group Port4 -color Gold /Simulate_this_for_Run_tests/out_resp4
add wave -noupdate -group Port4 -color Gold /Simulate_this_for_Run_tests/out_data4
add wave -noupdate -group {Optional Signals} /Simulate_this_for_Run_tests/C2/port1_invalid_op
add wave -noupdate -group {Optional Signals} /Simulate_this_for_Run_tests/C2/port2_invalid_op
add wave -noupdate -group {Optional Signals} /Simulate_this_for_Run_tests/C2/port3_invalid_op
add wave -noupdate -group {Optional Signals} /Simulate_this_for_Run_tests/C2/port4_invalid_op
add wave -noupdate -group {Optional Signals} /Simulate_this_for_Run_tests/C2/out_adder_overflow
add wave -noupdate -group {Optional Signals} /Simulate_this_for_Run_tests/C2/shift_overflow
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {464 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 255
configure wave -valuecolwidth 244
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {3064 ns}
