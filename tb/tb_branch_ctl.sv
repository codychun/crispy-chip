`include "riscv_pkg.sv"
`timescale 1ns/1ps

module tb_branch_ctl();

    // Testbench Inputs
    riscv_pkg::opcode_t opcode;
    riscv_pkg::br_f3_t  funct3;
    logic               less_than;
    logic               zero;

    // DUT Outputs
    logic [1:0]         pc_sel;

    branch_ctl dut (
        .opcode   (opcode),
        .funct3   (funct3),
        .less_than(less_than),
        .zero     (zero),
        .pc_sel   (pc_sel)
    );

    initial begin
        $display("=== TESTING BRANCH_CTL ===");
        
        // BEQ: Taken (zero = 1) -> Expect pc_sel = 2'b01
        opcode = riscv_pkg::OP_BRANCH;
        funct3 = riscv_pkg::F3_BEQ;
        zero = 1'b1; less_than = 1'b0;
        #10;
        assert(pc_sel == 2'b01) else $error("BEQ Taken Failed: pc_sel = %b (Expected: 01)", pc_sel);
        $display("BEQ Taken:     pc_sel = %b (Expected: 01)", pc_sel);

        // BEQ: Not Taken (zero = 0) -> Expect pc_sel = 2'b00
        zero = 1'b0;
        #10;
        assert(pc_sel == 2'b00) else $error("BEQ Not Taken Failed: pc_sel = %b (Expected: 00)", pc_sel);
        $display("BEQ Not Taken: pc_sel = %b (Expected: 00)", pc_sel);

        // BLT: Taken (less_than = 1) -> Expect pc_sel = 2'b01
        funct3 = riscv_pkg::F3_BLT;
        less_than = 1'b1;
        #10;
        assert(pc_sel == 2'b01) else $error("BLT Taken Failed: pc_sel = %b (Expected: 01)", pc_sel);
        $display("BLT Taken:     pc_sel = %b (Expected: 01)", pc_sel);

        // BLT: Not Taken (less_than = 0) -> Expect pc_sel = 2'b00
        less_than = 1'b0;
        #10;
        assert(pc_sel == 2'b00) else $error("BLT Not Taken Failed: pc_sel = %b (Expected: 00)", pc_sel);
        $display("BLT Not Taken: pc_sel = %b (Expected: 00)", pc_sel);

        // BGE: Taken (less_than = 0) -> Expect pc_sel = 2'b01
        funct3 = riscv_pkg::F3_BGE;
        less_than = 1'b0;
        #10;
        assert(pc_sel == 2'b01) else $error("BGE Taken Failed: pc_sel = %b (Expected: 01)", pc_sel);
        $display("BGE Taken:     pc_sel = %b (Expected: 01)", pc_sel);

        // BGE Not Taken (less_than = 1) -> Expect pc_sel = 2'b00
        less_than = 1'b1;
        #10;
        assert(pc_sel == 2'b00) else $error("BGE Not Taken Failed: pc_sel = %b (Expected: 00)", pc_sel);
        $display("BGE Not Taken: pc_sel = %b (Expected: 00)", pc_sel);

        // Unconditional JUMP -> Expect pc_sel = 2'b01
        opcode = riscv_pkg::OP_JUMP;
        #10;
        assert(pc_sel == 2'b01) else $error("JAL Jump Failed: pc_sel = %b (Expected: 01)", pc_sel);
        $display("JAL Jump:      pc_sel = %b (Expected: 01)", pc_sel);

        // JUMP_REG (JALR) -> Expect pc_sel = 2'b10
        opcode = riscv_pkg::OP_JUMP_REG;
        #10;
        assert(pc_sel == 2'b10) else $error("JALR Jump Failed: pc_sel = %b (Expected: 10)", pc_sel);
        $display("JALR Jump:     pc_sel = %b (Expected: 10)", pc_sel);

        $finish;
    end

endmodule
