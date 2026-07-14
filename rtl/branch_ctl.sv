`include "riscv_pkg.sv"

module branch_ctl(
    input riscv_pkg::opcode_t opcode,
    input riscv_pkg::br_f3_t  funct3,
    input logic               less_than,
    input logic               zero,

    output logic [1:0]        pc_sel        // Support expansion to JALR
);
    logic branch_taken;

    // Branch conditions based on instruction
    always_comb begin
        branch_taken = 1'b0;

        case (funct3)
            riscv_pkg::F3_BEQ: branch_taken = zero;
            riscv_pkg::F3_BLT: branch_taken = less_than;
            riscv_pkg::F3_BGE: branch_taken = ~less_than;

            default: ;  // Keep default safe values
        endcase
    end

    // PC source selection
    always_comb begin
        pc_sel = 2'b00; 

        case (opcode)
            riscv_pkg::OP_JUMP:    pc_sel = 2'b01;                          // Unconditional Jump
            riscv_pkg::OP_BRANCH:  pc_sel = (branch_taken) ? 2'b01 : 2'b00; // Conditional Branch, select based on instruction
            
            riscv_pkg::OP_LOAD, 
            riscv_pkg::OP_ALU_IMM, 
            riscv_pkg::OP_STORE,
            riscv_pkg::OP_ALU_REG: ; // Default execution: PC + 4
            default: ;
        endcase
    end

endmodule
