# CRISPy: Cody's really-Reduced Instruction Set Computer...yay!

CRISPy is a lightweight, single-cycle RV32I-subset RISC-V processor implemented in SystemVerilog. It features a modular Harvard architecture (separate instruction and data memory) designed to execute custom assembly routines (such as linked-list sorting) with high transparency and minimal hardware complexity.

---

## Purpose and Scope

The goal of the CRISPy project is to build a functional, transparent RISC-V core from the ground up while exploring HW/SW co-design, toolchain integration, and Verilog simulation nuances. 

Rather than implementing the full RV32I specification upfront, CRISPy targets a further reduced instruction subset tailored to run core control flow and data manipulation algorithms. Specifically, it targets a doubly-linked-list Insertion Sort algorithm I wrote in RISC-V Assembly for my Computer Archtecture class. Expanding on that class project, CRISPy aims to implement all of the instructions necessary to run this sorting algorithm (and other core functions) in a custom CPU core. Additional instructions and hardware extensions are added incrementally as the core matures.

### Key Target Features
* **ISA:** RV32I Subset (ALU operations, loads/stores, unconditional jumps, conditional branches).
* **Architecture:** Single-Cycle Harvard Architecture (separate instruction and data interfaces).
* **Verification Environment:** `iverilog` simulation with SystemVerilog Assertions (SVA) and GTKWave waveform dumps.
* **Software Toolchain:** GNU RISC-V Toolchain integration for assembling `.s` programs into memory initialization files.

---

## Hardware Architecture

CRISPy separates execution logic, decoding, and immediate generation into discrete, decoupled modules to ensure high clarity and easy extensibility.

![CRISPy Datapath Diagram](/img/datapath.png)

### Module Breakdown
* **`pc`**: Program Counter register with synchronous updates and active-low asynchronous reset.
* **`instr_mem`**: Asynchronous ROM storing instruction words (word-aligned addressing).
* **`decoder`**: Unpacks raw 32-bit instructions into opcode, register addresses (`rs1`, `rs2`, `rd`), and `funct3`/`funct7` fields.
* **`imm_gen`**: Generates sign-extended 32-bit immediates (I, S, B, U, J types) directly from raw instruction words.
* **`controller`**: Decodes opcodes and function bits into control signals (`reg_write_en`, `mem_read_en`, `mem_write_en`, MUX selectors).
* **`branch_ctl`**: Evaluates branch conditions (`zero`, `less_than`) against `funct3` and `opcode` to dictate `pc_sel`.
* **`regfile`**: 32 x 32-bit register file with asynchronous reads and synchronous writes. `x0` is hardwired to `0x0`.
* **`alu`**: Purely operational 32-bit math unit supporting addition, subtraction, logical shifts, and comparison flags.
* **`data_mem`**: Word-aligned RAM providing asynchronous reads and synchronous writes.

---

## Software Execution & Memory Verification

The primary verification workload for CRISPy is a doubly-linked-list insertion sort written in RISC-V assembly. 

### Linked List Sorting Flow
1. **Initial Array Setup:** Unsorted node structures containing payload data and pointers are initialized in `data_mem`.
2. **Head Pointer Tracking:** Register `x8` acts as the global head pointer.
3. **In-Place Mutation:** Swap and delete helper routines manipulate pointers dynamically in memory.
4. **Sorted List Output:** The core executes until `ebreak`, leaving a fully ordered linked list in memory.

#### Memory State Visualizations

| Initial Array in Memory | Head Pointer Location |
| :---: | :---: |
| ![Initial Array in Memory](/img/data_array.png) | ![Head Pointer in Memory](/img/list_head.png) |

| Sorted List Output (Post-Execution) |
| :---: |
| ![Sorted List Output](/img/sorted_list.png) |

---

## Design Considerations & Architectural Decisions

1. **Explicit Package Scoping vs. Broad Imports:**
   To prevent namespace pollution across multiple modules, RTL modules explicitly prefix package types (`riscv_pkg::opcode_t`). Testbenches import the package (`import riscv_pkg::*;`) to keep test stimulus expressive and readable.
2. **Decoupled Immediate Generator:**
   `imm_gen` inspects the raw instruction word directly to extract opcode bits rather than relying on decoded control signals from `decoder`. This reduces inter-module wiring overhead.
3. **Typedef Enforcement on Control, Raw Vectors on Math:**
   Control modules (`controller`, `branch_ctl`) strictly use SystemVerilog `enum` typedefs to restrict allowed state values. Operational units (`alu`) accept raw bit vectors to maintain domain generality.
4. **Scope Reduction (Omission of `BNE`):**
   The core intentionally omits instructions not required for basic algorithms. `BNE` is omitted in favor of `BEQ` combined with `JUMP`, keeping control flow unit gates minimal during initial bringup.
5. **Priority Inference Mitigation:**
   Careful structure is applied to avoid long `if-else` chains in control logic, preventing synthesis tools from inferring unintended priority logic networks (priority latches).

---

## Engineering Challenges & Solutions

### 1. Icarus Verilog Package Compilation Errors
* **Issue:** `iverilog` failed during compilation when `riscv_pkg.sv` was included by both design files and testbenches, causing double-definition errors despite passing `-I` and `-g2012` flags.
* **Solution:** Wrapped the package contents in an explicit preprocessor guard inside `riscv_pkg.sv`:
  ```systemverilog
  `ifndef RISCV_PKG_SV
  `define RISCV_PKG_SV
  package riscv_pkg;
      // Enums and Typedefs
  endpackage
  `endif
  ```

### 2. Bit-Slicing Restrictions in always_comb
* **Issue:** `iverilog` rejected dynamic bit-slicing within procedural blocks during shift operations inside the ALU.
* **Solution:** Pre-sliced variable bit fields prior to processing inside the main `always_comb` block.

### 3. C-Preprocessor Collisions in Assembly Files (.S vs .s)
* **Issue:** Naming assembly files with a capital .S caused `riscv-none-embed-gcc` to run the C preprocessor. Comments starting with # were interpreted as invalid preprocessor directives (e.g., # if ...).
* **Solution:** Renamed assembly source files to lowercase .s to bypass C preprocessing.

### 4. Separate Memory Address Spaces (Harvard Architecture)
* **Issue:** Software was initially written assuming unified memory. Splitting the processor into separate `instr_mem` and `data_mem` instances required distinct memory regions.
* **Solution:** Updated the linker script and Makefile to generate two memory files (program.hex and data.hex). The memory data started at higher address than instruction data, so I expanded the data memory address space to handle higher base offset ranges.

### 5. Uninitialized Stack Pointer (sp / x2)
* **Issue:** The register file lacked a global reset line, leaving x2 (sp) in an unknown (X) state at boot, breaking memory relative offsets and resulting in unwanted behavior when analyzing the waveforms and memory output snapshots.
* **Solution:** Added explicit initialization loops in regfile and updated assembly boot code to explicitly set x2 to the top of available RAM.

### 6. Linked-List Head Pointer Erasure Bug (x10 Corruption)
* **Issue:** Helper routines swap and delete return the address of the new head node in x10 if the front of the list changes, but return 0x0 if internal nodes are modified. The main loop blindly executed mv x8, x10, causing x8 (the global head pointer) to be overwritten with 0x0 whenever internal list nodes were swapped.
* **Solution:** Added a conditional branch guard in the assembly code to skip updating x8 if x10 returns zero:
    ```asm
    beq x10, x0, skip_head_update
    mv  x8, x10
    skip_head_update:
    ```

## Directory Structure

```txt
.
├── docs/
│   └── images/              # Architecture diagrams and memory dumps
├── include/
│   └── riscv_pkg.sv         # SystemVerilog package (typedefs, enums, constants)
├── rtl/
│   ├── alu.sv               # Arithmetic Logic Unit
│   ├── branch_ctl.sv        # Branch decision logic
│   ├── controller.sv        # Main datapath control unit
│   ├── data_mem.sv          # Data RAM
│   ├── decoder.sv           # Instruction decoder
│   ├── imm_gen.sv           # Immediate value generator
│   ├── instr_mem.sv         # Instruction ROM
│   ├── pc.sv                # Program Counter register
│   └── regfile.sv           # Register File
├── tb/
│   ├── tb_alu.sv            # Testbenches for individual units
│   ├── tb_controller.sv
│   ├── tb_decoder.sv
│   ├── tb_regfile.sv
│   └── tb_top.sv            # Top-level integration testbench
├── sw/
│   ├── link.ld              # Linker script for memory partitioning
│   └── sort_list.s          # Linked-list insertion sort program
├── Makefile                 # Build and simulation automation script
└── README.md
```

## Getting Started & Build System

### Prerequisites
Ensure the following toolchain packages are installed and available in your system PATH with `./setup.sh`:
* Icarus Verilog (iverilog) >= 11.0
* GTKWave (gtkwave)
* GNU RISC-V Toolchain (riscv64-unknown-elf-gcc or riscv-none-embed-gcc)

### Makefile Commands
| Command | Description |
| :---: | :---: |
| make all | Compiles assembly software, builds all RTL modules, and prepares simulation targets. |
| make software | Assembles .s code into program.hex and data.hex memory init files. |
| make compile | Compiles SystemVerilog RTL and testbenches using iverilog -g2012. |
| make run | Runs the simulation executable and executes SystemVerilog assertions. |
| make wave | Opens GTKWave with the dumped .vcd trace files. |
| make test | Executes unit testbenches for all individual sub-modules. |
| make clean | Removes build artifacts, .hex files, and .vcd traces. |

### Running the Full Verification Flow
1. Clone the repository:
    ```bash
    git clone https://github.com/codychun/crispy-chip
    cd crispy-chip
    ```
2. Assemble software and run full system simulation:
    ```bash
    make run
    ```
    The top-level testbench running insertion sort (`tb_crispy_top.sv`) will be run by default. To change the test, specify the test name using the `TEST` argument. The name of the test must match the rtl file name (the testbench file name without the tb_ prefix):
    ```bash
    make run TEST=alu
    ```
3. Inspect waveforms:
    ```bash
    make wave
    ```
    Customize GTKWave aplication GUI window with a `.gtkwaverc` file in root directory:
    ```
    # Disable the splash screen on startup
    splash_disable 1

    # Increase font sizes for the signal list and wave timeline
    fontname_signals Sans 16
    fontname_wave    Sans 16
    fontname_logfile Sans 16

    # Make the initial window size larger
    initial_window_x 1200
    initial_window_y 800

    # Make the wave traces thicker/easier to see
    wave_scrolling 1
    ```
