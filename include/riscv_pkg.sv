// Instruction Field Constants

`ifndef RISCV_PKG_SV
`define RISCV_PKG_SV
package riscv_pkg;
    // Instruction Opcodes
    typedef enum logic [6:0] {
        OP_LOAD    = 7'b0000011,
        OP_ALU_IMM = 7'b0010011,
        OP_STORE   = 7'b0100011,
        OP_ALU_REG = 7'b0110011,
        OP_BRANCH  = 7'b1100011,
        OP_JUMP    = 7'b1101111
    } opcode_t;

    // Instruction funct3
    // ALU-specific funct3
    typedef enum logic [2:0] {
        F3_ADD_SUB  = 3'b000,
        F3_SLL  = 3'b001,
        F3_SRL  = 3'b101
    } alu_f3_t;
    
    // Branch-specific funct3
    typedef enum logic [2:0] {
        F3_BEQ  = 3'b000,
        F3_BLT  = 3'b100,
        F3_BGE  = 3'b101
    } br_f3_t;

    // Memory-specific funct3
    // Support future expansion
    typedef enum logic [2:0] {
        F3_LW_SW = 3'b010
    } mem_f3_t;

    // Instruction funct7
    // Don't need enum: just two options
    // Keeping out of typedef allows us to just compare one bit
    localparam logic [6:0] F7_STD  = 7'b0000000;    // add, sll, srl
    localparam logic [6:0] F7_ALT  = 7'b0100000;    // sub

    typedef enum logic [3:0] {
        ALU_ADD    = 4'b0000,
        ALU_SUB    = 4'b0001,
        ALU_SRL    = 4'b0010,
        ALU_SLL    = 4'b0011
    } alu_op_t;
    
endpackage

`endif // RISCV_PKG_SV
