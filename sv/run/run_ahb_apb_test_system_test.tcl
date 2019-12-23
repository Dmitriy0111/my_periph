#
# File          :   run_ahb_apb_test_system_test.tcl
# Autor         :   Vlasov D.V.
# Data          :   2019.12.23
# Language      :   tcl
# Description   :   This is script for running simulation process
# Copyright(c)  :   2019 Vlasov D.V.
#

vlog -sv ../sv/common/*.*v
vlog -sv ../sv/gpio/rtl/*.*v
vlog -sv ../sv/uart/rtl/*.*v
vlog -sv ../sv/tmr/rtl/*.*v
vlog -sv ../sv/spi/rtl/*.*v
vlog -sv ../sv/bus/ahb/rtl/*.*v
vlog -sv ../sv/bus/bridge/rtl/*.*v
vlog -sv ../sv/bus/apb/rtl/*.*v
vlog -sv ../sv/test_system/tb/*.*v

vsim -novopt work.ahb_apb_test_system_tb

add wave -divider  "testbench signals"
add wave -position insertpoint sim:/ahb_apb_test_system_tb/*

run -all

wave zoom full

#quit
