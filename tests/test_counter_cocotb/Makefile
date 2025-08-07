#############################################################
# Makefile for cocotb simulation
#############################################################

TOPLEVEL_LANG = verilog

SIM ?= icarus
WAVES ?= 1
WAVE_VIEWER ?= gtkwave

COCOTB_HDL_TIMEUNIT = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

DUT      = counter
TOPLEVEL = $(DUT)
MODULE   = test_$(DUT)
VERILOG_SOURCES += ../../rtl/$(DUT).sv

# module parameters
export PARAM_WIDTH ?= 4

ifeq ($(SIM), icarus)
	PLUSARGS += -fst

	COMPILE_ARGS += $(foreach v,$(filter PARAM_%,$(.VARIABLES)),-P $(TOPLEVEL).$(subst PARAM_,,$(v))=$($(v)))

	ifeq ($(WAVES), 1)
		VERILOG_SOURCES += iverilog_dump.v
		COMPILE_ARGS += -s iverilog_dump
	endif
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

#############################################################
# Extra configuration for iverilog (must be placed after including Makefile.sim)
#############################################################

iverilog_dump.v:
	echo 'module iverilog_dump();' > $@
	echo 'initial begin' >> $@
	echo '    $$dumpfile("$(TOPLEVEL).fst");' >> $@
	echo '    $$dumpvars(0, $(TOPLEVEL));' >> $@
	echo 'end' >> $@
	echo 'endmodule' >> $@

#############################################################
# Generic waveform viewer configuration
#############################################################

WAVE_FILE ?= $(TOPLEVEL).fst
wave:
	@if [ -f "$(WAVE_FILE)" ]; then \
		$(WAVE_VIEWER) $(WAVE_FILE); \
	else \
		echo "Waveform file $(WAVE_FILE) not found."; \
	fi

#############################################################
# Clean
#############################################################

clean::
	@rm -rf __pycache__
	@rm -rf .pytest_cache
	@rm -rf sim_build
	@rm -rf modelsim.ini
	@rm -rf results.xml
	@rm -rf transcript
	@rm -rf vsim.wlf
	@rm -rf iverilog_dump.v
	@rm -rf dump.fst $(TOPLEVEL).fst
	@rm -rf wave.sav
