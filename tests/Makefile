HDL_DIR := ../rtl
BUILD_DIR := ./build
TB_DIR := ./testbenches
WAVEFORM_DIR := ./waveforms
UART_DIR := ./uart
CPP_SRC_DIR := ./src

HDL_FILES := $(shell find $(HDL_DIR) -name '*.sv' -or -name '*.v' -or -name '*.svh')
TB_FILES := $(shell find $(TB_DIR) -name '*.sv' -or -name '*.v')

# Names of testbenches, derived from testbench filenames (foo_tb.sv -> foo_tb)
TB_NAMES := $(basename $(notdir $(TB_FILES)))

VERILATOR_BUILD_DIR := $(BUILD_DIR)/verilator
VERILATOR_FLAGS := --binary -j 0 --trace --no-stop-fail --assert
VERILATOR_CPP_FLAGS := --cc --exe --build -j 0 --timing

# One .vcd target per discovered testbench
WAVEFORMS := $(addprefix $(WAVEFORM_DIR)/,$(addsuffix .vcd,$(TB_NAMES)))

all: $(WAVEFORMS)

# Verilator: pattern rule, one build dir per testbench so runs don't clobber each other
$(WAVEFORM_DIR)/%.vcd: $(HDL_FILES) $(TB_FILES)
	mkdir -p $(VERILATOR_BUILD_DIR)/$* $(WAVEFORM_DIR)
	verilator $(VERILATOR_FLAGS) -Mdir $(VERILATOR_BUILD_DIR)/$* --top-module $* $(HDL_FILES) $(TB_FILES)
	$(VERILATOR_BUILD_DIR)/$*/V$*

$(UART_DIR)/uart_sim: $(HDL_FILES) $(TB_FILES)
	mkdir -p $(UART_DIR)/pty
	verilator $(VERILATOR_CPP_FLAGS) -Mdir $(UART_DIR)/$* $(CPP_SRC_DIR)/main.cpp --top-module top_level $(HDL_FILES) $(TB_FILES)
	./start.sh

.PHONY: clean all
clean:
	rm -rf $(BUILD_DIR) $(WAVEFORM_DIR) $(UART_DIR)

FORCE: ;
