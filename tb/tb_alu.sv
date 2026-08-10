`include "riscv_pkg.sv"
`timescale  1ns /1ps

module tb_alu;

    // Testbench Inputs
    reg  [31:0] t_a;
    reg  [31:0] t_b;
    reg  [3:0]  t_alu_op;

    // DUT Outputs
    logic [31:0] t_result;
    logic        t_zero;
    logic        t_less_than;

    logic signed [31:0] signed_t_a, signed_t_b, signed_t_result;

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

    always @(*) begin
        signed_t_a      = $signed(t_a);
        signed_t_b      = $signed(t_b);
        signed_t_result = $signed(t_result);
    end

    // Test Stimulus
    initial begin  
        import riscv_pkg::*;
         
        $monitor("Time = %-5t | IN: A = %5d, B = %5d, OP = %2d | OUT: RES = %5d, Z = %b, LT = %b", 
          $time, signed_t_a, signed_t_b, t_alu_op, signed_t_result, t_zero, t_less_than);

        // Test Case 1: Standard Addition (ADDI / ADD)
        t_a = 32'd15; t_b = 32'd10; t_alu_op = ALU_ADD;
        #10;    // One clock cycle delay, Single cycle ALU
        assert(t_result == 32'd25) else $error("ADD Failed: result = %0d (Expected: 25)", t_result);
        assert(t_zero == 1'b0) else $error("Zero Flag Failed: zero = %b (Expected: 0)", t_zero);
        assert(t_less_than == 1'b0) else $error("Less Than Flag Failed: less_than = %b (Expected: 0)", t_less_than);

        // Test Case 2: Subtraction Equal (BEQ check)
        t_a = 32'd42; t_b = 32'd42; t_alu_op = ALU_SUB;
        #10;
        assert(t_result == 32'd0)    else $error("SUB Failed: result = %0d (Expected: 0)", t_result);
        assert(t_zero == 1'b1)       else $error("Zero Flag Failed: zero = %b (Expected: 1)", t_zero);
        assert(t_less_than == 1'b0)  else $error("Less Than Flag Failed: less_than = %b (Expected: 0)", t_less_than);

        // Test Case 3: Signed Comparison Less Than (BLT / BGE check)
        t_a = -32'd5; t_b = 32'd2; t_alu_op = ALU_SUB;
        #10;
        assert(t_result == -32'd7)   else $error("SUB Failed: result = %0d (Expected: -7)", t_result);
        assert(t_less_than == 1'b1)  else $error("Signed Less Than Flag Failed: less_than = %b (Expected: 1)", t_less_than);
        assert(t_zero == 1'b0)       else $error("Zero Flag false positive: zero = %b (Expected: 0)", t_zero);
    end

endmodule
