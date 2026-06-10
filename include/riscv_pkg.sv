package riscv_pkg;
   typedef enum logic [6:0] {
       OP_ALU_REG = 7'b0110011,
       OP_ALU_IMM = 7'b0010011,
       OP_LOAD    = 7'b0000011,
       OP_STORE   = 7'b0100011,
       OP_BRANCH  = 7'b1100011
   } opcode_t;
endpackage