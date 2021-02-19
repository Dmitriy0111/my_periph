#
# File          : run_gpio_simple_test.tcl
# Autor         : Vlasov D.V.
# Data          : 2021.02.18
# Language      : tcl
# Description   : This is script for running simulation process
# Copyright(c)  : 2021 Vlasov D.V.
#

# compile design
vcom -2008 ../rtl/vhdl/common_pkg/*
vcom -2008 ../rtl/vhdl/regs/*
vcom -2008 ../rtl/vhdl/gpio/gpio_pkg.vhd
vcom -2008 ../rtl/vhdl/gpio/gpio.vhd

vlog -sv ../rtl/sv/regs/*.*v
vlog -sv ../rtl/sv/gpio/*.*v
# compile testbench
vlog -sv ../tb/gpio/*

vsim -novopt work.gpio_tb

add wave -divider  "testbench signals"
add wave -position insertpoint sim:/gpio_tb/*
add wave -divider  "dut sv signals"
add wave -position insertpoint sim:/gpio_tb/dut_sv/*
add wave -divider  "dut vhdl signals"
add wave -position insertpoint sim:/gpio_tb/dut_vhd/*

run -all

wave zoom full

quit
