`include "include/riscv_pkg.sv"

module imm_gen(
    input logic  [31:0] instr,
    output logic [31:0] imm
);
    // Opcode
    logic [6:0] opcode;
    assign opcode = instr[6:0];

    // Intermediate Immediates
    logic [31:0] imm_i;
    logic [31:0] imm_s;
    logic [31:0] imm_sb;
    logic [31:0] imm_uj;
    // Immediates padded to 32-bits, sign preserved
    assign imm_i  = 32'(signed'(instr[31:20]));
    assign imm_s  = 32'(signed'({instr[31:25], instr[11:7]}));
    assign imm_sb = 32'(signed'({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}));
    assign imm_uj = 32'(signed'({instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}));

    always_comb begin
        // MUX chooses which immediate to use based on opcode (instruction type)
        case (opcode)
            OP_ALU_IMM: imm = imm_i;
            OP_LOAD:    imm = imm_i;
            OP_STORE:   imm = imm_s;
            OP_BRANCH:  imm = imm_sb;
            OP_JUMP:    imm = imm_uj;
            default:    imm = 32'b0;
        endcase
    end

endmodule