`include "riscv_pkg.sv"
`timescale  1ns /1ps

module tb_alu;

    // Testbench Inputs
    reg  [31:0] t_a;
    reg  [31:0] t_b;
    reg  [3:0]  t_alu_op;

    // DUT Outputs
    wire [31:0] t_result;
    wire        t_zero;
    wire        t_less_than;

    // Instantiate DUT
    alu uut (
        .a(t_a),
        .b(t_b),
        .alu_op(t_alu_op),

        .result(t_result),
        .zero(t_zero),
        .less_than(t_less_than)
    );

    // GTKWave dumpfile
    initial begin
        $dumpfile("build/alu_dump.vcd");
        $dumpvars(0, tb_alu);
    end

    // Test Stimulus
    initial begin  
        import riscv_pkg::*;
         
        $monitor("Time = %-5t | IN: A = %10d, B = %10d, OP = %2d | OUT: RES = %10d, Z = %b, LT = %b", 
          $time, t_a, t_b, t_alu_op, t_result, t_zero, t_less_than);

        // Test Case 1: Standard Addition (ADDI / ADD)
        t_a = 32'd15; t_b = 32'd10; t_alu_op = ALU_ADD;
        #10;    // One clock cycle delay, Single cycle ALU
        assert(t_result == 32'd25) else $error("ADD Failed!");

        // Test Case 2: Subtraction Equal (BEQ check)
        t_a = 32'd42; t_b = 32'd42; t_alu_op = ALU_SUB;
        #10;
        assert(t_result == 32'd0)    else $error("SUB Failed!");
        assert(t_zero == 1'b1)       else $error("Zero Flag Failed on Equal!");
        assert(t_less_than == 1'b0)  else $error("Less Than Flag false positive!");

        // Test Case 3: Signed Comparison Less Than (BLT / BGE check)
        t_a = -32'd5; t_b = 32'd2; t_alu_op = ALU_SUB;
        #10;
        assert(t_less_than == 1'b1)  else $error("Signed Less Than Flag Failed!");
        assert(t_zero == 1'b0)       else $error("Zero Flag false positive!");

        $display("ALU Phase 1 Verification Passed successfully!");
    end

endmodule


