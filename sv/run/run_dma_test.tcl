#
# File          :   run_dma_test.tcl
# Autor         :   Vlasov D.V.
# Data          :   2019.12.19
# Language      :   tcl
# Description   :   This is script for running simulation process
# Copyright(c)  :   2019 Vlasov D.V.
#

vlog -sv ../sv/common/*.*v
vlog -sv ../sv/dma/rtl/*.*v
vlog -sv ../sv/dma/tb/*.*v

vsim -novopt work.dma_tb

add wave -divider  "testbench signals"
add wave -position insertpoint sim:/dma_tb/*
add wave -divider  "dut signals"
add wave -position insertpoint sim:/dma_tb/dut/*

run -all

wave zoom full

#quit
