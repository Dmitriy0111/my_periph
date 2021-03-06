#
# File          :   run_uart_test.tcl
# Autor         :   Vlasov D.V.
# Data          :   2019.12.04
# Language      :   tcl
# Description   :   This is script for running simulation process
# Copyright(c)  :   2019 - 2020 Vlasov D.V.
#

vlog -sv ../sv/common/*.*v
vlog -sv ../sv/uart/rtl/*.*v
vlog -sv ../sv/uart/tb/*.*v

vsim -novopt work.uart_tb

add wave -divider  "testbench signals"
add wave -position insertpoint sim:/uart_tb/*
add wave -divider  "dut signals"
add wave -position insertpoint sim:/uart_tb/dut/*

run -all

wave zoom full

#quit
