
# Compiler configuration
SIM   = iverilog
VVP   = vvp
VIEW  = gtkwave
FLAGS = -g2012 -I include	# Enable SystemVerilog IEEE 1800-2012, Look for pkg in /include 

# Directory configuration
RTL_DIR   = rtl
TB_DIR    = tb
BUILD_DIR = build

# Test name: TEST= (same as rtl file name)
# Default to crispy_top if none specified
TEST ?= crispy_top

# Map tests to target files
TARGET = $(BUILD_DIR)/$(TEST)_test
WAVE   = $(BUILD_DIR)/$(TEST)_dump.vcd

# Source configuration
ifeq ($(TEST), crispy_top)
    # Top-level test requires all RTL files
    SRCS  = $(RTL_DIR)/alu.sv \
			$(RTL_DIR)/branch_ctl.sv \
			$(RTL_DIR)/controller.sv \
			$(RTL_DIR)/data_mem.sv \
			$(RTL_DIR)/decodeer.sv \
			$(RTL_DIR)/imm_gen.sv \
			$(RTL_DIR)/instr_mem.sv \
			$(RTL_DIR)/pc.sv \
			$(RTL_DIR)/regfile.sv \
			$(RTL_DIR)/top.sv $(TB_DIR)/tb_top.sv
else
	SRCS = $(RTL_DIR)/$(TEST).sv $(TB_DIR)/tb_$(TEST).sv
endif

# Build Rules
.PHONY: all compile run wave clean

all: run

compile: $(TARGET)

# Compile code
$(TARGET): $(SRCS)
	@mkdir -p $(BUILD_DIR)
	$(SIM) $(FLAGS) -o $@ $^

# Run simulation
run: $(TARGET)
	$(VVP) $<

# Open Waveforms
wave: $(WAVE)
	$(VIEW) $(WAVE) &

super_clean:
	rm -rf $(BUILD_DIR)
