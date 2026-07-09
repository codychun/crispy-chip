`include "../include/riscv_pkg.sv"

module alu(
    input logic  [31:0] a,          // Operand A (rs1_data)
    input logic  [31:0] b,          // Operand B (rs2_data or Imm)
    input logic  [3:0]  alu_op,

    output logic [31:0] result,
    output logic        zero,       // BEQ: High if result == 0
    output logic        less_than   // BLT/BGE: High if A < B
);
    // Branch flags updated instantly
    assign zero      = (result == 32'b0);
    assign less_than = ($signed(a) < $signed(b));

    always_comb begin
        result = 31'b0;

        case (alu_op)
            ALU_ADD: begin
                result = a + b;
            end
            
            ALU_SUB: begin
                result = a - b;
            end
            
            ALU_SLL: begin
                // In RISC-V, shift amounts only use the lower 5 bits (0 to 31 shifts)
                result = a << b[4:0];
            end
            
            ALU_SRL: begin
                result = a >> b[4:0];
            end

            default: begin
                result = 32'b0;
            end
        endcase
    end

endmodule