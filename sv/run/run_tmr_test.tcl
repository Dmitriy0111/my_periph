#
# File          :   run_tmr_test.tcl
# Autor         :   Vlasov D.V.
# Data          :   2019.12.17
# Language      :   tcl
# Description   :   This is script for running simulation process
# Copyright(c)  :   2019 - 2020 Vlasov D.V.
#

vlog -sv ../sv/common/*.*v
vlog -sv ../sv/tmr/rtl/*.*v
vlog -sv ../sv/tmr/tb/*.*v

vsim -novopt work.tmr_tb

add wave -divider  "testbench signals"
add wave -position insertpoint sim:/tmr_tb/*
add wave -divider  "dut signals"
add wave -position insertpoint sim:/tmr_tb/dut/*

run -all

wave zoom full

#quit
