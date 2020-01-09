#
# File          :   run_gpio_test.tcl
# Autor         :   Vlasov D.V.
# Data          :   2019.12.06
# Language      :   tcl
# Description   :   This is script for running simulation process
# Copyright(c)  :   2019 - 2020 Vlasov D.V.
#

vlog -sv ../sv/common/*.*v
vlog -sv ../sv/gpio/rtl/*.*v
vlog -sv ../sv/gpio/tb/*.*v

vsim -novopt work.gpio_tb

add wave -divider  "testbench signals"
add wave -position insertpoint sim:/gpio_tb/*
add wave -divider  "dut signals"
add wave -position insertpoint sim:/gpio_tb/dut/*

run -all

wave zoom full

#quit
