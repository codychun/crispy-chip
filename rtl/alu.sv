`include "riscv_pkg.sv"   // Copy-paste the package text here

module alu(
    input logic     [31:0] a,          // Operand A (rs1_data)
    input logic     [31:0] b,          // Operand B (rs2_data or Imm)
    input riscv_pkg::alu_op_t alu_op,

    output logic    [31:0] result,
    output logic           zero,       // BEQ: High if result == 0
    output logic           less_than   // BLT/BGE: High if A < B
);
    // Branch flags updated instantly
    assign zero      = (result == 32'b0);
    assign less_than = ($signed(a) < $signed(b));

    // Temporary wire for shifting.
    // iverilog doesn't support bitslicing in always blocks yet
    wire [4:0] shift_amt = b[4:0];

    always_comb begin
        result = 32'b0;

        case (alu_op)
            riscv_pkg::ALU_ADD: result = a + b;
            riscv_pkg::ALU_SUB: result = a - b;
            // shift amounts only use the lower 5 bits (0 to 31 shifts)
            riscv_pkg::ALU_SLL: result = a << shift_amt;
            riscv_pkg::ALU_SRL: result = a >> shift_amt;
            default: ;
        endcase
    end

endmodule
