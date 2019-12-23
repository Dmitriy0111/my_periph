#
# File          :   run_ahb2apb_bridge_test.tcl
# Autor         :   Vlasov D.V.
# Data          :   2019.12.23
# Language      :   tcl
# Description   :   This is script for running simulation process
# Copyright(c)  :   2019 Vlasov D.V.
#

vlog -sv ../sv/common/*.*v
vlog -sv ../sv/bus/bridge/rtl/*.*v
vlog -sv ../sv/bus/bridge/tb/*.*v

vsim -novopt work.ahb2apb_bridge_tb

add wave -divider  "testbench signals"
add wave -position insertpoint sim:/ahb2apb_bridge_tb/*
add wave -divider  "dut signals"
add wave -position insertpoint sim:/ahb2apb_bridge_tb/dut/*

run -all

wave zoom full

#quit
