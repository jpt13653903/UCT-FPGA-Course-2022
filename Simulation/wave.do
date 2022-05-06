vlib work
vlog -work work {../Counter/Counter.v}
vlog -work work {../Counter/Counter_TB.v}
vsim work.Counter_TB

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /Counter_TB/ipReset
add wave -noupdate -radix hexadecimal /Counter_TB/opLED
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {80084746 ns} 0}
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
configure wave -timelineunits us
update
WaveRestoreZoom {0 ns} {1050 ms}

run {1 sec}
wave zoom full

