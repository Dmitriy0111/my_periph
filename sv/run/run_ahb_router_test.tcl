#
# File          :   run_ahb_router_test.tcl
# Autor         :   Vlasov D.V.
# Data          :   2019.12.18
# Language      :   tcl
# Description   :   This is script for running simulation process
# Copyright(c)  :   2019 - 2020 Vlasov D.V.
#

vlog -sv ../sv/common/*.*v
vlog -sv ../sv/bus/ahb/rtl/*.*v
vlog -sv ../sv/bus/ahb/tb/*.*v

vsim -novopt work.ahb_router_tb

add wave -divider  "testbench signals"
add wave -position insertpoint sim:/ahb_router_tb/*
add wave -divider  "dut signals"
add wave -position insertpoint sim:/ahb_router_tb/dut/*

run -all

wave zoom full

#quit
