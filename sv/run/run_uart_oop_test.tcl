#
# File          :   run_uart_oop_test.tcl
# Autor         :   Vlasov D.V.
# Data          :   2019.12.04
# Language      :   tcl
# Description   :   This is script for running simulation process
# Copyright(c)  :   2019 - 2020 Vlasov D.V.
#

# compile common rtl
vlog -sv ../sv/common/*.*v
# compile design rtl
vlog -sv ../sv/uart/rtl/*.*v
# compile testbench
vlog -sv ../dvv_vm/*.*v
vlog -sv ../sv/uart/tb/if/*.*v
vlog -sv ../sv/uart/tb/test_classes/uart_test_pkg.sv 
vlog -sv ../sv/uart/tb/uart_ctb.*v

vsim -novopt work.uart_ctb

add wave -divider  "testbench signals"
add wave -position insertpoint sim:/uart_ctb/*
add wave -divider  "dut signals"
add wave -position insertpoint sim:/uart_ctb/dut_gen/dut/*

run -all

coverage report -detail -cvg -directive -config -comments -file sif_cov.log -noa /uart_test_pkg/sif_cov/sif_cg

wave zoom full

#quit
