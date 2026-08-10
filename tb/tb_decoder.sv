`timescale 1ns/1ps

module tb_decoder();

    // Testbench Inputs
    logic [31:0] instr;

    // DUT Outputs
    logic [6:0]  opcode;
    logic [4:0]  rd, rs1, rs2;
    logic [2:0]  funct3;
    logic [6:0]  funct7;

    decoder dut (
        .instr (instr),
        .opcode(opcode),
        .rd    (rd),
        .rs1   (rs1),
        .rs2   (rs2),
        .funct3(funct3),
        .funct7(funct7)
    );

    initial begin
        $display("=== TESTING DECODER ===");

        // Instruction: add x3, x1, x2 -> 0x002081b3
        // funct7 = 0000000, rs2 = 00010 (2), rs1 = 00001 (1), funct3 = 000, rd = 00011 (3), opcode = 0110011 (0x33)
        instr = 32'h002081b3; #10;

        assert(opcode == 7'b0110011) else $error("Opcode mismatch");
        assert(rd     == 5'd3) else $error("rd mismatch");
        assert(rs1    == 5'd1) else $error("rs1 mismatch");
        assert(rs2    == 5'd2) else $error("rs2 mismatch");
        assert(funct3 == 3'b000) else $error("funct3 mismatch");
        assert(funct7 == 7'b0000000) else $error("funct7 mismatch");
        
        $display("Instruction: 0x%h", instr);
        $display("Opcode: 0x%h  (Expected: 0x33)", opcode);
        $display("rd:     %0d   (Expected: 3)", rd);
        $display("rs1:    %0d   (Expected: 1)", rs1);
        $display("rs2:    %0d   (Expected: 2)", rs2);
        $display("funct3: %0d   (Expected: 0)", funct3);
        $display("funct7: 0x%h  (Expected: 0x00)", funct7);

        $finish;
    end

endmodule
