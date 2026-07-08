// Instruction Field Constants

package riscv_pkg;
    typedef enum logic [6:0] {
        OP_LOAD    = 7'b0000011,
        OP_ALU_IMM = 7'b0010011,
        OP_STORE   = 7'b0100011,
        OP_ALU_REG = 7'b0110011,
        OP_BRANCH  = 7'b1100011,
        OP_JUMP    = 7'b1101111
    } opcode_t;

    typedef enum logic [2:0] {
        FUNCT3_LW   = 3'b010;
        FUNCT3_ADDI = 3'b000;
        FUNCT3_SW   = 3'b010;
        FUNCT3_ADD  = 3'b000;
        FUNCT3_SUB  = 3'b000;
        FUNCT3_SRL  = 3'b101;
        FUNCT3_SLL  = 3'b001;
        FUNCT3_BEQ  = 3'b000;
        FUNCT3_BGE  = 3'b100;
        FUNCT3_BLT  = 3'b101;
    } funct3_t;

    typedef enum logic [6:0] {
        FUNCT7_ADD  = 7'b0000000;
        FUNCT7_SUB  = 7'b0100000;
        FUNCT7_SRL  = 7'b0000000;
        FUNCT7_SLL  = 7'b0000000;
    } funct7_t;

    typedef enum logic [3:0] {
        ALU_ADD    = 4'b0000;
        ALU_SUB    = 4'b0001;
        ALU_SRL    = 4'b0010;
        ALU_SLL    = 4'b0011;
        ALU_CMP    = 4'b0100;
    } alu_op_t;
    
endpackage