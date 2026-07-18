`include "riscv_pkg.sv"

module controller(
    input riscv_pkg::opcode_t opcode,
    input riscv_pkg::alu_f3_t funct3,
    input logic funct7_5,                // Only Bit 5 of funct7 changes

    output riscv_pkg::alu_op_t alu_op,   // 11 operations (5 ALU operations --> Extra space later expansion)
    output logic reg_write_en,
    output logic alu_src_sel,
    output logic mem_write_en,
    output logic mem_read_en,
    output logic mem_to_reg_sel,
    output logic ebreak
);
    always_comb begin
        // Reset Default Output Controls
        alu_op         = riscv_pkg::ALU_ADD; // Default ADDI
        reg_write_en   = 1'b0;
        alu_src_sel    = 1'b1;    // 0: reg, 1: imm
        mem_write_en   = 1'b0;
        mem_read_en    = 1'b0;
        mem_to_reg_sel = 1'b0;    // 0: alu, 1: mem
        ebreak         = 1'b0;    // 0: program continues, 1: program ends

        // Combined Datapath Controller
        case (opcode)
            riscv_pkg::OP_ALU_IMM: begin
                    alu_op       = riscv_pkg::ALU_ADD;
                    reg_write_en = 1'b1;
                end
            riscv_pkg::OP_LOAD: begin
                    alu_op         = riscv_pkg::ALU_ADD;
                    reg_write_en   = 1'b1;
                    mem_read_en    = 1'b1;
                    mem_to_reg_sel = 1'b1;
                end 
            riscv_pkg::OP_STORE: begin
                    alu_op       = riscv_pkg::ALU_ADD;
                    mem_write_en = 1'b1;
                end
            riscv_pkg::OP_BRANCH: begin
                    alu_op       = riscv_pkg::ALU_SUB;
                    alu_src_sel  = 1'b0;
                end
            riscv_pkg::OP_JUMP: begin
                    alu_op       = riscv_pkg::ALU_ADD;
                    reg_write_en = 1'b1;
                end
            riscv_pkg::OP_ALU_REG: begin
                    reg_write_en = 1'b1;
                    alu_src_sel  = 1'b0;

                    case (funct3)
                        riscv_pkg::F3_ADD_SUB:  alu_op = (funct7_5) ? riscv_pkg::ALU_SUB : riscv_pkg::ALU_ADD;
                        riscv_pkg::F3_SLL:  alu_op = riscv_pkg::ALU_SLL;
                        riscv_pkg::F3_SRL:  alu_op = riscv_pkg::ALU_SRL;
                        
                        default: ;  // Keep default safe values
                    endcase
                end
            riscv_pkgg::OP_SYSTEM: begin
                ebreak = 1'b1;
            end
            
            default: ;  // Keep default safe values
        endcase
    end
endmodule
