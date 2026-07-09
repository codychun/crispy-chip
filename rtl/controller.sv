`include "../include/riscv_pkg.sv"

module controller(
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,

    output logic reg_write_en,
    output logic alu_src_sel,
    output logic [3:0] alu_op,   // 11 operations (5 ALU operations --> Extra space later expansion)
    output logic mem_write_en,
    output logic mem_read_en,
    output logic mem_to_reg
);
    always_comb begin
        // Reset Default Output Controls
        reg_write_en = 1'b0;
        alu_src_sel  = 1'b1;    // 0: reg, 1: imm
        alu_op       = ALU_ADD; // Default ADDI
        mem_write_en = 1'b0;
        mem_read_en  = 1'b0;
        mem_to_reg   = 1'b0;    // 0: alu, 1: mem

        // Combined Datapath Controller
        case (opcode)
            OP_ALU_IMM: begin
                    reg_write_en = 1'b1;
                    alu_op       = ALU_ADD;
                end
            OP_LOAD: begin
                    reg_write_en = 1'b1;
                    alu_op       = ALU_ADD;
                    mem_read_en  = 1'b1;
                    mem_to_reg   = 1'b1;
                end 
            OP_STORE: begin
                    alu_op       = ALU_ADD;
                    mem_write_en = 1'b1;
                end
            OP_BRANCH: begin
                    alu_src_sel  = 1'b0;
                    alu_op       = ALU_SUB;
                end
            OP_JUMP: begin
                    reg_write_en = 1'b1;
                    alu_op       = ALU_ADD;
                end
            OP_ALU_REG: begin
                    reg_write_en = 1'b1;
                    alu_src_sel  = 1'b0;
                    case (funct3)
                        FUNCT3_ADD:  alu_op = (funct7[5]) ? ALU_SUB : ALU_ADD;
                        FUNCT3_SLL:  alu_op = ALU_SLL;
                        FUNCT3_SRL:  alu_op = ALU_SRL;
                        default:     alu_op = ALU_ADD;
                    endcase
                end
            default: ;  // Keep default safe values
        endcase
    end
endmodule
