#
# File          :   run_apb_router_test.tcl
# Autor         :   Vlasov D.V.
# Data          :   2019.12.23
# Language      :   tcl
# Description   :   This is script for running simulation process
# Copyright(c)  :   2019 - 2020 Vlasov D.V.
#

vlog -sv ../sv/common/*.*v
vlog -sv ../sv/bus/apb/rtl/*.*v
vlog -sv ../sv/bus/apb/tb/*.*v

vsim -novopt work.apb_router_tb

add wave -divider  "testbench signals"
add wave -position insertpoint sim:/apb_router_tb/*
add wave -divider  "dut signals"
add wave -position insertpoint sim:/apb_router_tb/dut/*

run -all

wave zoom full

#quit
