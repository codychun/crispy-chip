`include "riscv_pkg.sv"

module imm_gen(
    input  logic [31:0] instr,

    output logic [31:0] imm
);
    // Opcode
    riscv_pkg::opcode_t opcode;
    assign opcode = riscv_pkg::opcode_t'(instr[6:0]);

    // Intermediate Immediates
    logic [31:0] imm_i;
    logic [31:0] imm_s;
    logic [31:0] imm_sb;
    logic [31:0] imm_uj;

    // Immediates padded to 32-bits using explicit bit-replication
    assign imm_i  = { {20{instr[31]}}, instr[31:20] };
    assign imm_s  = { {20{instr[31]}}, instr[31:25], instr[11:7] };
    assign imm_sb = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
    assign imm_uj = { {11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0 };

    always_comb begin
        imm = 32'b0;

        // MUX chooses which immediate to use based on opcode (instruction type)
        case (opcode)
            riscv_pkg::OP_ALU_IMM: imm = imm_i;
            riscv_pkg::OP_LOAD:    imm = imm_i;
            riscv_pkg::OP_STORE:   imm = imm_s;
            riscv_pkg::OP_BRANCH:  imm = imm_sb;
            riscv_pkg::OP_JUMP:    imm = imm_uj;

            riscv_pkg::OP_ALU_REG: ;
            default: ;
        endcase
    end

endmodule
