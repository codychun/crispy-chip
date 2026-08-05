# ==========================================
# Toolchain Configuration
# ==========================================
# Software Toolchain (RISC-V)
RISCV_PREFIX = riscv64-unknown-elf-
CC           = $(RISCV_PREFIX)gcc
OBJCOPY      = $(RISCV_PREFIX)objcopy

# Hardware Toolchain (Icarus Verilog)
SIM   = iverilog
VVP   = vvp
VIEW  = gtkwave
FLAGS = -g2012 -I include    # Enable SystemVerilog IEEE 1800-2012, Look for pkg

# ==========================================
# Directory & File Configuration
# ==========================================
RTL_DIR   = rtl
TB_DIR    = tb
BUILD_DIR = build
ASM_SRC   = insertion_sort.s
HEX_OUT   = $(BUILD_DIR)/program.hex
DATA_HEX  = $(BUILD_DIR)/data.hex
ELF_OUT   = $(BUILD_DIR)/sort.elf

# Test name: TEST= (same as rtl file name)
# Default to crispy_top if none specified
TEST ?= crispy_top

# Map tests to target files
TARGET = $(BUILD_DIR)/$(TEST)_test
WAVE   = $(BUILD_DIR)/$(TEST)_dump.vcd

# Source configuration
ifeq ($(TEST), crispy_top)
	# Top-level test requires all RTL files
	SRCS = $(RTL_DIR)/alu.sv \
	       $(RTL_DIR)/branch_ctl.sv \
	       $(RTL_DIR)/controller.sv \
	       $(RTL_DIR)/data_mem.sv \
	       $(RTL_DIR)/decoder.sv \
	       $(RTL_DIR)/imm_gen.sv \
	       $(RTL_DIR)/instr_mem.sv \
	       $(RTL_DIR)/pc.sv \
	       $(RTL_DIR)/regfile.sv \
	       $(RTL_DIR)/crispy_top.sv \
	       $(TB_DIR)/tb_crispy_top.sv
	
	# Only require building the .hex file if we are simulating the full CPU
	HEX_DEP = $(HEX_OUT)
else
	# Unit tests only need their specific files
	SRCS = $(RTL_DIR)/$(TEST).sv $(TB_DIR)/tb_$(TEST).sv
	HEX_DEP = 
endif

# ==========================================
# Build Rules
# ==========================================
.PHONY: all compile run wave clean super_clean software

all: run

# --- 1. Software Build Rules ---
software: $(HEX_OUT)

$(HEX_OUT): $(ASM_SRC)
	@mkdir -p $(BUILD_DIR)
	$(CC) -march=rv32i -mabi=ilp32 -nostdlib -Ttext=0 -o $(ELF_OUT) $(ASM_SRC)
	# Extract Instruction memory (.text section)
	$(OBJCOPY) -O verilog -j .text --verilog-data-width=4 $(ELF_OUT) $(HEX_OUT)
	# Extract Data memory (.data section)
	$(OBJCOPY) -O verilog -j .data --verilog-data-width=4 $(ELF_OUT) $(DATA_HEX)

# --- 2. Hardware Compile Rules ---
compile: $(TARGET)

# Notice $(SRCS) instead of $^ so we don't accidentally pass the .hex file to iverilog!
$(TARGET): $(SRCS) $(HEX_DEP)
	@mkdir -p $(BUILD_DIR)
	$(SIM) $(FLAGS) -o $@ $(SRCS)

# --- 3. Run Simulation ---
run: compile
	$(VVP) $(TARGET)

# --- 4. Open Waveforms ---
wave: 
	$(VIEW) $(WAVE) &

# --- 5. Clean Up ---
clean: super_clean

super_clean:
	rm -rf $(BUILD_DIR)
	rm -f *.vvp *.vcd *.hex