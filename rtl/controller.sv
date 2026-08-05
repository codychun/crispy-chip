`include "riscv_pkg.sv"

module controller(
    input riscv_pkg::opcode_t opcode,
    input riscv_pkg::alu_f3_t funct3,
    input logic funct7_5,                // Only Bit 5 of funct7 changes

    output riscv_pkg::alu_op_t alu_op,
    output logic reg_write_en,
    output logic mem_write_en,
    output logic mem_read_en,
    output logic alu_a_sel,
    output logic alu_b_sel,
    output logic [1:0] wb_sel,
    output logic ebreak
);
    always_comb begin
        // Reset Default Output Controls
        alu_op       = riscv_pkg::ALU_ADD; // Default ADDI
        reg_write_en = 1'b0;
        alu_a_sel    = 1'b0;    // 0: rs1_data, 1: pc
        alu_b_sel    = 1'b0;    // 0: reg, 1: imm
        mem_write_en = 1'b0;
        mem_read_en  = 1'b0;
        wb_sel       = 2'b00;   // 00: alu, 01: mem, 10: PC+4 (JALR)
        ebreak       = 1'b0;    // 0: program continues, 1: program ends

        // Combined Datapath Controller
        case (opcode)
            riscv_pkg::OP_ALU_IMM: begin
                    alu_op       = riscv_pkg::ALU_ADD;      // Currently only implements ADDI, chhange later if adding others (SLLI, ANDI, ORI, etc)
                    reg_write_en = 1'b1;
                    alu_b_sel    = 1'b1;
                end
            riscv_pkg::OP_LOAD: begin
                    alu_op       = riscv_pkg::ALU_ADD;
                    reg_write_en = 1'b1;
                    mem_read_en  = 1'b1;
                    wb_sel       = 2'b01;
                    alu_b_sel    = 1'b1;
                end 
            riscv_pkg::OP_STORE: begin
                    alu_op       = riscv_pkg::ALU_ADD;
                    mem_write_en = 1'b1;
                    alu_b_sel    = 1'b1;
                end
            riscv_pkg::OP_BRANCH: begin
                    alu_op     = riscv_pkg::ALU_SUB;
                end
            riscv_pkg::OP_JUMP: begin
                    alu_op       = riscv_pkg::ALU_ADD;
                    reg_write_en = 1'b1;
                    wb_sel       = 2'b10;
                end
            riscv_pkg::OP_ALU_REG: begin
                    reg_write_en = 1'b1;
                    case (funct3)
                        riscv_pkg::F3_ADD_SUB:  alu_op = riscv_pkg::alu_op_t'( (funct7_5) ? riscv_pkg::ALU_SUB : riscv_pkg::ALU_ADD );
                        riscv_pkg::F3_SLL:      alu_op = riscv_pkg::ALU_SLL;
                        riscv_pkg::F3_SRL:      alu_op = riscv_pkg::ALU_SRL;
                        default: ;  // Keep default safe values
                    endcase
                end
            riscv_pkg::OP_AUIPC: begin
                    alu_a_sel    = 1'b1;
                    alu_b_sel    = 1'b1;
                    reg_write_en = 1'b1;
                end
            riscv_pkg::OP_SYSTEM: ebreak = 1'b1;

        endcase
    end
endmodule
