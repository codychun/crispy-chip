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
        assert(alu_op       == riscv_pkg::ALU_ADD) else $error("ALU_IMM: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_ADD);
        assert(reg_write_en == 1'b1) else $error("ALU_IMM: reg_write_en = %b (Expected: 1)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("ALU_IMM: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b1) else $error("ALU_IMM: alu_b_sel = %b (Expected: 1)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("ALU_IMM: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("ALU_IMM: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b00) else $error("ALU_IMM: wb_sel = %b (Expected: 00)", wb_sel);
        assert(ebreak       == 1'b0) else $error("ALU_IMM: ebreak = %b (Expected: 0)", ebreak);

        $display("ALU_IMM: alu_op=%0h reg_wr=%b alu_b_sel=%b", 
                 alu_op, reg_write_en, alu_b_sel);

        // Test LOAD
        opcode = riscv_pkg::OP_LOAD; 
        #10;
        assert(alu_op == riscv_pkg::ALU_ADD) else $error("LOAD: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_ADD);
        assert(reg_write_en == 1'b1) else $error("LOAD: reg_write_en = %b (Expected: 1)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("LOAD: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b1) else $error("LOAD: alu_b_sel = %b (Expected: 1)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("LOAD: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b1) else $error("LOAD: mem_read_en = %b (Expected: 1)", mem_read_en);
        assert(wb_sel       == 2'b01) else $error("LOAD: wb_sel = %b (Expected: 01)", wb_sel);
        assert(ebreak       == 1'b0) else $error("LOAD: ebreak = %b (Expected: 0)", ebreak);

        $display("LOAD:  alu_op=%0h reg_wr=%b mem_rd=%b wb_sel=%b alu_b_sel=%b", 
                 alu_op, reg_write_en, mem_read_en, wb_sel, alu_b_sel);

        // Test STORE
        opcode = riscv_pkg::OP_STORE; 
        #10;
        assert(alu_op == riscv_pkg::ALU_ADD) else $error("STORE: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_ADD);
        assert(reg_write_en == 1'b0) else $error("STORE: reg_write_en = %b (Expected: 0)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("STORE: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b1) else $error("STORE: alu_b_sel = %b (Expected: 1)", alu_b_sel);
        assert(mem_write_en == 1'b1) else $error("STORE: mem_write_en = %b (Expected: 1)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("STORE: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b00) else $error("STORE: wb_sel = %b (Expected: 00)", wb_sel);
        assert(ebreak       == 1'b0) else $error("STORE: ebreak = %b (Expected: 0)", ebreak);

        $display("STORE: reg_wr=%b mem_wr=%b alu_b_sel=%b", 
                 reg_write_en, mem_write_en, alu_b_sel);

        // Test BRANCH
        opcode = riscv_pkg::OP_BRANCH;
        #10;
        assert(alu_op       == riscv_pkg::ALU_SUB) else $error("BRANCH: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_SUB);
        assert(reg_write_en == 1'b0) else $error("BRANCH: reg_write_en = %b (Expected: 0)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("BRANCH: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b0) else $error("BRANCH: alu_b_sel = %b (Expected: 0)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("BRANCH: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("BRANCH: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b00) else $error("BRANCH: wb_sel = %b (Expected: 00)", wb_sel);
        assert(ebreak       == 1'b0) else $error("BRANCH: ebreak = %b (Expected: 0)", ebreak);

        $display("BRANCH: alu_op=%0h", alu_op);

        // Test JUMP
        opcode = riscv_pkg::OP_JUMP;
        #10;
        assert(alu_op       == riscv_pkg::ALU_ADD) else $error("JUMP: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_ADD);
        assert(reg_write_en == 1'b1) else $error("JUMP: reg_write_en = %b (Expected: 1)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("JUMP: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b0) else $error("JUMP: alu_b_sel = %b (Expected: 0)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("JUMP: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("JUMP: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b10) else $error("JUMP: wb_sel = %b (Expected: 10)", wb_sel);
        assert(ebreak       == 1'b0) else $error("JUMP: ebreak = %b (Expected: 0)", ebreak);

        $display("JUMP:  alu_op=%0h reg_wr=%b wb_sel=%b", 
                 alu_op, reg_write_en, wb_sel);

        // Test ALU_REG
        opcode = riscv_pkg::OP_ALU_REG; 
        alu_funct3 = riscv_pkg::F3_ADD_SUB; 

        // ADD
        funct7_5 = 1'b0; 
        #10; 
        assert(alu_op       == riscv_pkg::ALU_ADD) else $error("ADD: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_ADD);
        assert(reg_write_en == 1'b1) else $error("ADD: reg_write_en = %b (Expected: 1)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("ADD: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b0) else $error("ADD: alu_b_sel = %b (Expected: 0)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("ADD: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("ADD: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b00) else $error("ADD: wb_sel = %b (Expected: 00)", wb_sel);
        assert(ebreak       == 1'b0) else $error("ADD: ebreak = %b (Expected: 0)", ebreak);    
        $display("ADD:   alu_op=%0h reg_wr=%b", alu_op, reg_write_en);

        // SUB
        funct7_5 = 1'b1; 
        #10; 
        assert(alu_op       == riscv_pkg::ALU_SUB) else $error("SUB: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_SUB);
        assert(reg_write_en == 1'b1) else $error("SUB: reg_write_en = %b (Expected: 1)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("SUB: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b0) else $error("SUB: alu_b_sel = %b (Expected: 0)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("SUB: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("SUB: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b00) else $error("SUB: wb_sel = %b (Expected: 00)", wb_sel);
        assert(ebreak       == 1'b0) else $error("SUB: ebreak = %b (Expected: 0)", ebreak);  
        $display("SUB:   alu_op=%0h reg_wr=%b", alu_op, reg_write_en);

        // SLL
        alu_funct3 = riscv_pkg::F3_SLL; funct7_5 = 1'b0; 
        #10;
        assert(alu_op       == riscv_pkg::ALU_SLL) else $error("SLL: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_SLL);
        assert(reg_write_en == 1'b1) else $error("SLL: reg_write_en = %b (Expected: 1)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("SLL: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b0) else $error("SLL: alu_b_sel = %b (Expected: 0)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("SLL: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("SLL: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b00) else $error("SLL: wb_sel = %b (Expected: 00)", wb_sel);
        assert(ebreak       == 1'b0) else $error("SLL: ebreak = %b (Expected: 0)", ebreak);  
        $display("SLL:   alu_op=%0h reg_wr=%b", alu_op, reg_write_en);

        // SRL
        alu_funct3 = riscv_pkg::F3_SRL; funct7_5 = 1'b0; 
        #10;
        assert(alu_op       == riscv_pkg::ALU_SRL) else $error("SRL: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_SRL);
        assert(reg_write_en == 1'b1) else $error("SRL: reg_write_en = %b (Expected: 1)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("SRL: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b0) else $error("SRL: alu_b_sel = %b (Expected: 0)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("SRL: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("SRL: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b00) else $error("SRL: wb_sel = %b (Expected: 00)", wb_sel);
        assert(ebreak       == 1'b0) else $error("SRL: ebreak = %b (Expected: 0)", ebreak);  
        $display("SRL:   alu_op=%0h reg_wr=%b", alu_op, reg_write_en);

        // Test AUIPC
        opcode = riscv_pkg::OP_AUIPC;
        #10;
        assert(alu_op       == riscv_pkg::ALU_ADD) else $error("AUIPC: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_ADD);
        assert(reg_write_en == 1'b1) else $error("AUIPC: reg_write_en = %b (Expected: 1)", reg_write_en);
        assert(alu_a_sel    == 1'b1) else $error("AUIPC: alu_a_sel = %b (Expected: 1)", alu_a_sel);
        assert(alu_b_sel    == 1'b1) else $error("AUIPC: alu_b_sel = %b (Expected: 1)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("AUIPC: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("AUIPC: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b00) else $error("AUIPC: wb_sel = %b (Expected: 00)", wb_sel);
        assert(ebreak       == 1'b0) else $error("AUIPC: ebreak = %b (Expected: 0)", ebreak);

        $display("AUIPC: alu_op=%0h reg_wr=%b alu_a_sel=%b alu_b_sel=%b", 
                 alu_op, reg_write_en, alu_a_sel, alu_b_sel);

        // Test SYSTEM (ebreak)
        opcode = riscv_pkg::OP_SYSTEM; 
        #10;
        assert(alu_op       == riscv_pkg::ALU_ADD) else $error("EBREAK: alu_op = %0h (Expected: %0h)", alu_op, riscv_pkg::ALU_ADD);
        assert(reg_write_en == 1'b0) else $error("EBREAK: reg_write_en = %b (Expected: 1)", reg_write_en);
        assert(alu_a_sel    == 1'b0) else $error("EBREAK: alu_a_sel = %b (Expected: 0)", alu_a_sel);
        assert(alu_b_sel    == 1'b0) else $error("EBREAK: alu_b_sel = %b (Expected: 0)", alu_b_sel);
        assert(mem_write_en == 1'b0) else $error("EBREAK: mem_write_en = %b (Expected: 0)", mem_write_en);
        assert(mem_read_en  == 1'b0) else $error("EBREAK: mem_read_en = %b (Expected: 0)", mem_read_en);
        assert(wb_sel       == 2'b00) else $error("EBREAK: wb_sel = %b (Expected: 00)", wb_sel);
        assert(ebreak       == 1'b1) else $error("EBREAK: ebreak = %b (Expected: 1)", ebreak);  
        $display("EBREAK: ebreak=%b", ebreak);

        $finish;
    end

endmodule
