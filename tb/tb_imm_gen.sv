`include "riscv_pkg.sv"
`timescale 1ns/1ps


module tb_imm_gen();

    // Testbench Inputs
    logic [31:0] instr;

    // DUT Outputs
    logic [31:0] imm;

    imm_gen dut (
        .instr(instr),
        .imm  (imm)
    );

    initial begin
        $display("=== TESTING IMM_GEN ===");

        // I-Type: addi x1, x2, -5 (0xFFB10093)
        instr = 32'hffb10093; #10;
        assert(imm == -32'd5) else $error("I-Type immediate generation failed!");
        $display("I-Type  (-5):  imm = %d", $signed(imm));

        // S-Type: sw x1, 8(x2) (0x00112423)
        instr = 32'h00112423; #10;
        assert(imm == 32'd8) else $error("S-Type immediate generation failed!");
        $display("S-Type  (+8):  imm = %d", $signed(imm));

        // SB-Type: beq x1, x2, 12 (0x00208663)
        instr = 32'h00208663; #10;
        assert(imm == 32'd12) else $error("SB-Type immediate generation failed!");
        $display("SB-Type (+12): imm = %d", $signed(imm));

        // U-Type: auipc x1, 0x12345 (0x12345097)
        instr = 32'h12345097; #10;
        assert(imm == 32'h12345000) else $error("U-Type immediate generation failed!");
        $display("U-Type:        imm =  0x%h", imm);

        // UJ-Type: jal x1, 16 (0x010000ef)
        instr = 32'h010000ef; #10;
        assert(imm == 32'd16) else $error("UJ-Type immediate generation failed!");
        $display("UJ-Type (+16): imm = %d", $signed(imm));

        $finish;
    end

endmodule
