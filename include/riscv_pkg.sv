// Instruction Opcode Constants

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
        FUNC3_LW   = 3'b010;
        FUNC3_ADDI = 3'b000;
        FUNC3_SW   = 3'b010;
        FUNC3_ADD  = 3'b000;
        FUNC3_SUB  = 3'b000;
        FUNC3_SRL  = 3'b101;
        FUNC3_SLL  = 3'b001;
        FUNC3_BEQ  = 3'b000;
        FUNC3_BGE  = 3'b100;
        FUNC3_BLT  = 3'b101;
    } func3_t;

    typedef enum logic [6:0] {
        FUNC7_ADD  = 7'b0000000;
        FUNC7_SUB  = 7'b0100000;
        FUNC7_SRL  = 7'b0000000;
        FUNC7_SLL  = 7'b0000000;
    } func7_t;
    
endpackage