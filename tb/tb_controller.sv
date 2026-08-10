`timescale 1ns/1ps
`include "riscv_pkg.sv"

module tb_controller();

    // Testbench Inputs
    riscv_pkg::opcode_t opcode;
    riscv_pkg::alu_f3_t alu_funct3;
    logic               funct7_5;

    // DUT Outputs
    riscv_pkg::alu_op_t alu_op;
    logic               reg_write_en, mem_write_en, mem_read_en;
    logic               alu_a_sel, alu_b_sel, ebreak;
    logic [1:0]         wb_sel;

    controller dut (
        .opcode      (opcode),
        .funct3      (alu_funct3),
        .funct7_5    (funct7_5),
        .alu_op      (alu_op),
        .reg_write_en(reg_write_en),
        .mem_write_en(mem_write_en),
        .mem_read_en (mem_read_en),
        .alu_a_sel   (alu_a_sel),
        .alu_b_sel   (alu_b_sel),
        .wb_sel      (wb_sel),
        .ebreak      (ebreak)
    );

    initial begin
        $display("=== TESTING CONTROLLER ===");

        // Test ALU_IMM
        opcode = riscv_pkg::OP_ALU_IMM; alu_funct3 = riscv_pkg::F3_ADD_SUB; funct7_5 = 1'b0; 
        #10;
        assert(alu_op       == riscv_pkg::ALU_ADD) else $error("ALU_IMM Failed: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_ADD);
        assert(reg_write_en == 1'b1) else $error("ALU_IMM Failed: reg_write_en = %b (Expected: 1)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("ALU_IMM Failed: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b1) else $error("ALU_IMM Failed: alu_b_sel = %b (Expected: 1)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("ALU_IMM Failed: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("ALU_IMM Failed: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b00) else $error("ALU_IMM Failed: wb_sel = %b (Expected: 00)", wb_sel);
        assert(ebreak       == 1'b0) else $error("ALU_IMM Failed: ebreak = %b (Expected: 0)", ebreak);

        $display("ALU_IMM: alu_op=%0h reg_wr=%b alu_b_sel=%b", 
                 alu_op, reg_write_en, alu_b_sel);

        // Test LOAD
        opcode = riscv_pkg::OP_LOAD; 
        #10;
        assert(alu_op == riscv_pkg::ALU_ADD) else $error("LOAD Failed: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_ADD);
        assert(reg_write_en == 1'b1) else $error("LOAD Failed: reg_write_en = %b (Expected: 1)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("LOAD Failed: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b1) else $error("LOAD Failed: alu_b_sel = %b (Expected: 1)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("LOAD Failed: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b1) else $error("LOAD Failed: mem_read_en = %b (Expected: 1)", mem_read_en);
        assert(wb_sel       == 2'b01) else $error("LOAD Failed: wb_sel = %b (Expected: 01)", wb_sel);
        assert(ebreak       == 1'b0) else $error("LOAD Failed: ebreak = %b (Expected: 0)", ebreak);

        $display("LOAD:  alu_op=%0h reg_wr=%b mem_rd=%b wb_sel=%b alu_b_sel=%b", 
                 alu_op, reg_write_en, mem_read_en, wb_sel, alu_b_sel);

        // Test STORE
        opcode = riscv_pkg::OP_STORE; 
        #10;
        assert(alu_op == riscv_pkg::ALU_ADD) else $error("STORE Failed: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_ADD);
        assert(reg_write_en == 1'b0) else $error("STORE Failed: reg_write_en = %b (Expected: 0)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("STORE Failed: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b1) else $error("STORE Failed: alu_b_sel = %b (Expected: 1)", alu_b_sel);
        assert(mem_write_en == 1'b1) else $error("STORE Failed: mem_write_en = %b (Expected: 1)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("STORE Failed: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b00) else $error("STORE Failed: wb_sel = %b (Expected: 00)", wb_sel);
        assert(ebreak       == 1'b0) else $error("STORE Failed: ebreak = %b (Expected: 0)", ebreak);

        $display("STORE: reg_wr=%b mem_wr=%b alu_b_sel=%b", 
                 reg_write_en, mem_write_en, alu_b_sel);

        // Test BRANCH
        opcode = riscv_pkg::OP_BRANCH;
        #10;
        assert(alu_op       == riscv_pkg::ALU_SUB) else $error("BRANCH Failed: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_SUB);
        assert(reg_write_en == 1'b0) else $error("BRANCH Failed: reg_write_en = %b (Expected: 0)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("BRANCH Failed: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b0) else $error("BRANCH Failed: alu_b_sel = %b (Expected: 0)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("BRANCH Failed: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("BRANCH Failed: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b00) else $error("BRANCH Failed: wb_sel = %b (Expected: 00)", wb_sel);
        assert(ebreak       == 1'b0) else $error("BRANCH Failed: ebreak = %b (Expected: 0)", ebreak);

        $display("BRANCH: alu_op=%0h", alu_op);

        // Test JUMP
        opcode = riscv_pkg::OP_JUMP;
        #10;
        assert(alu_op       == riscv_pkg::ALU_ADD) else $error("JUMP Failed: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_ADD);
        assert(reg_write_en == 1'b1) else $error("JUMP Failed: reg_write_en = %b (Expected: 1)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("JUMP Failed: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b0) else $error("JUMP Failed: alu_b_sel = %b (Expected: 0)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("JUMP Failed: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("JUMP Failed: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b10) else $error("JUMP Failed: wb_sel = %b (Expected: 10)", wb_sel);
        assert(ebreak       == 1'b0) else $error("JUMP Failed: ebreak = %b (Expected: 0)", ebreak);

        $display("JUMP:  alu_op=%0h reg_wr=%b wb_sel=%b", 
                 alu_op, reg_write_en, wb_sel);

        // Test ALU_REG
        opcode = riscv_pkg::OP_ALU_REG; 
        alu_funct3 = riscv_pkg::F3_ADD_SUB; 

        // ADD
        funct7_5 = 1'b0; 
        #10; 
        assert(alu_op       == riscv_pkg::ALU_ADD) else $error("ADD Failed: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_ADD);
        assert(reg_write_en == 1'b1) else $error("ADD Failed: reg_write_en = %b (Expected: 1)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("ADD Failed: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b0) else $error("ADD Failed: alu_b_sel = %b (Expected: 0)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("ADD Failed: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("ADD Failed: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b00) else $error("ADD Failed: wb_sel = %b (Expected: 00)", wb_sel);
        assert(ebreak       == 1'b0) else $error("ADD Failed: ebreak = %b (Expected: 0)", ebreak);    
        $display("ADD:   alu_op=%0h reg_wr=%b", alu_op, reg_write_en);

        // SUB
        funct7_5 = 1'b1; 
        #10; 
        assert(alu_op       == riscv_pkg::ALU_SUB) else $error("SUB Failed: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_SUB);
        assert(reg_write_en == 1'b1) else $error("SUB Failed: reg_write_en = %b (Expected: 1)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("SUB Failed: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b0) else $error("SUB Failed: alu_b_sel = %b (Expected: 0)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("SUB Failed: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("SUB Failed: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b00) else $error("SUB Failed: wb_sel = %b (Expected: 00)", wb_sel);
        assert(ebreak       == 1'b0) else $error("SUB Failed: ebreak = %b (Expected: 0)", ebreak);  
        $display("SUB:   alu_op=%0h reg_wr=%b", alu_op, reg_write_en);

        // SLL
        alu_funct3 = riscv_pkg::F3_SLL; funct7_5 = 1'b0; 
        #10;
        assert(alu_op       == riscv_pkg::ALU_SLL) else $error("SLL Failed: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_SLL);
        assert(reg_write_en == 1'b1) else $error("SLL Failed: reg_write_en = %b (Expected: 1)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("SLL Failed: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b0) else $error("SLL Failed: alu_b_sel = %b (Expected: 0)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("SLL Failed: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("SLL Failed: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b00) else $error("SLL Failed: wb_sel = %b (Expected: 00)", wb_sel);
        assert(ebreak       == 1'b0) else $error("SLL Failed: ebreak = %b (Expected: 0)", ebreak);  
        $display("SLL:   alu_op=%0h reg_wr=%b", alu_op, reg_write_en);

        // SRL
        alu_funct3 = riscv_pkg::F3_SRL; funct7_5 = 1'b0; 
        #10;
        assert(alu_op       == riscv_pkg::ALU_SRL) else $error("SRL Failed: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_SRL);
        assert(reg_write_en == 1'b1) else $error("SRL Failed: reg_write_en = %b (Expected: 1)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("SRL Failed: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b0) else $error("SRL Failed: alu_b_sel = %b (Expected: 0)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("SRL Failed: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("SRL Failed: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b00) else $error("SRL Failed: wb_sel = %b (Expected: 00)", wb_sel);
        assert(ebreak       == 1'b0) else $error("SRL Failed: ebreak = %b (Expected: 0)", ebreak);  
        $display("SRL:   alu_op=%0h reg_wr=%b", alu_op, reg_write_en);

        // Test AUIPC
        opcode = riscv_pkg::OP_AUIPC;
        #10;
        assert(alu_op       == riscv_pkg::ALU_ADD) else $error("AUIPC Failed: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_ADD);
        assert(reg_write_en == 1'b1) else $error("AUIPC Failed: reg_write_en = %b (Expected: 1)", reg_write_en);
        assert(alu_a_sel    == 1'b1) else $error("AUIPC Failed: alu_a_sel = %b (Expected: 1)", alu_a_sel);
        assert(alu_b_sel    == 1'b1) else $error("AUIPC Failed: alu_b_sel = %b (Expected: 1)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("AUIPC Failed: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("AUIPC Failed: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b00) else $error("AUIPC Failed: wb_sel = %b (Expected: 00)", wb_sel);
        assert(ebreak       == 1'b0) else $error("AUIPC Failed: ebreak = %b (Expected: 0)", ebreak);

        $display("AUIPC: alu_op=%0h reg_wr=%b alu_a_sel=%b alu_b_sel=%b", 
                 alu_op, reg_write_en, alu_a_sel, alu_b_sel);

        // Test SYSTEM (ebreak)
        opcode = riscv_pkg::OP_SYSTEM; 
        #10;
        assert(alu_op       == riscv_pkg::ALU_ADD) else $error("EBREAK Failed: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_ADD);
        assert(reg_write_en == 1'b0) else $error("EBREAK Failed: reg_write_en = %b (Expected: 1)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("EBREAK Failed: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b0) else $error("EBREAK Failed: alu_b_sel = %b (Expected: 0)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("EBREAK Failed: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("EBREAK Failed: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b00) else $error("EBREAK Failed: wb_sel = %b (Expected: 00)", wb_sel);
        assert(ebreak       == 1'b1) else $error("EBREAK Failed: ebreak = %b (Expected: 1)", ebreak);  
        $display("EBREAK: ebreak=%b", ebreak);

        $finish;
    end

endmodule
