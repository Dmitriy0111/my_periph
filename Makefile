
help:
	$(info make help           - show this message)
	$(info make clean          - delete synth and simulation folders)
	$(info make sim            - the same as sim_gui)
	$(info make sim_cmd        - run simulation in Modelsim (console mode))
	$(info make sim_gui        - run simulation in Modelsim (gui mode))
	$(info Open and read the Makefile for details)
	@true

PWD     := $(shell pwd)
RUN_DIR  = $(PWD)/run

PERIPH ?= gpio

TB_TYPE ?= simple

########################################################
# common make targets

show_pwd:
	PWD

clean: \
	sim_clean \
	log_clean

sim_all: \
	sim_cmd 

sim: sim_gui

########################################################
# simulation - Modelsim

SIM_SCRIPT_NAME = run_$(PERIPH)_$(TB_TYPE)_test.tcl

VSIM_DIR = $(PWD)/sim_modelsim1

VLIB_BIN = cd $(VSIM_DIR) && vlib
VLOG_BIN = cd $(VSIM_DIR) && vlog
VSIM_BIN = cd $(VSIM_DIR) && vsim

VSIM_OPT_COMMON += -do $(RUN_DIR)/$(SIM_SCRIPT_NAME) -onfinish final

VSIM_OPT_CMD     = -c
VSIM_OPT_CMD    += -onfinish exit

VSIM_OPT_GUI     = -gui -onfinish stop

sim_clean:
	rm -rfd $(VSIM_DIR)

sim_dir: sim_clean
	mkdir $(VSIM_DIR)

sim_cmd: sim_dir
	$(VSIM_BIN) $(VSIM_OPT_COMMON) $(VSIM_OPT_CMD)

sim_gui: sim_dir
	$(VSIM_BIN) $(VSIM_OPT_COMMON) $(VSIM_OPT_GUI) &

log_clean:
	rm -rfd .log
