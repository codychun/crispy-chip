`timescale 1ns/1ps

module tb_instr_mem();

    // Testbench Inputs
    logic [31:0] instr_addr;

    // DUT Outputs
    logic [31:0] instr_data;

    instr_mem dut (
        .instr_addr(instr_addr),
        .instr_data(instr_data)
    );

    initial begin
        $display("=== TESTING INSTR_MEM ===");

        // Manually load test pattern into ROM array
        dut.rom[0] = 32'h00500093; // addi x1, x0, 5
        dut.rom[1] = 32'h00a00113; // addi x2, x0, 10

        // Read byte address 0x00000000 (Word index 0)
        instr_addr = 32'h00000000; #10;
        assert(instr_data == 32'h00500093) else $error("Test failed: instr_data = 0x%h (Expected: 0x00500093)", instr_data);
        $display("Addr 0x0: instr = 0x%h (Expected: 00500093)", instr_data);
        

        // Read byte address 0x00000004 (Word index 1)
        instr_addr = 32'h00000004; #10;
        assert(instr_data == 32'h00a00113) else $error("Test failed: instr_data = 0x%h (Expected: 0x00a00113)", instr_data);
        $display("Addr 0x4: instr = 0x%h (Expected: 00a00113)", instr_data);

        $finish;
    end

endmodule
