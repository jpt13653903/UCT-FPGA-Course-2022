onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /Counter_TB/ipClk
add wave -noupdate -radix hexadecimal /Counter_TB/ipReset
add wave -noupdate -radix hexadecimal /Counter_TB/opLed
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {175980019 ns} 0} {{Cursor 2} {178000385 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 205
configure wave -valuecolwidth 40
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
configure wave -timelineunits ms
update
WaveRestoreZoom {168936800 ns} {199045861 ns}
