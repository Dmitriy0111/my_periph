#
# File          :   run_spi_test.tcl
# Autor         :   Vlasov D.V.
# Data          :   2019.12.13
# Language      :   tcl
# Description   :   This is script for running simulation process
# Copyright(c)  :   2019 - 2020 Vlasov D.V.
#

vlog -sv ../sv/common/*.*v
vlog -sv ../sv/spi/rtl/*.*v
vlog -sv ../sv/spi/tb/*.*v

vsim -novopt work.spi_tb

add wave -divider  "testbench signals"
add wave -position insertpoint sim:/spi_tb/*
add wave -divider  "dut signals"
add wave -position insertpoint sim:/spi_tb/dut/*

run -all

wave zoom full

#quit
