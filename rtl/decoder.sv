`include "include/riscv_pkg.sv"

module(
    input logic [31:0] instr,
    output logic [6:0] opcode,
    output logic [4:0] rd,      // destination register, immediate for S/SB-type
    output logic [2:0] func3,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [6:0] func7,  // func7 for R-type, immediate for others
    output logic       reg_write_en
); 

    assign opcode = input[6:0];
    assign rd = input[11:7];
    assign func3 = input[12:12];
    assign rs1 = input[19:15];
    assign rs2 = input[24:20];
    assign func7 = input[31:25];

    always_comb begin
        reg_write_en = 1'b0;    // default register safe

        case (opcode)
            OP_ALU_REG: reg_write_en = 1'b1;    // R-Type (ADD, SUB, ...)
            OP_ALU_IMM: reg_write_en = 1'b1;    // I-type (ADDI, ...)
            OP_ALU_ST:  reg_write_en = 1'b0;    // S-type (SW, ...)
            default:    reg_write_en = 1'b0;    // defualt register safe

        endcase
    end

endmodule