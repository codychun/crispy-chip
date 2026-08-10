`timescale 1ns/1ps

module tb_data_mem();

    // Testbench Inputs
    logic        clk;
    logic        mem_write_en;
    logic        mem_read_en;
    logic [31:0] mem_addr;
    logic [31:0] mem_write_data;

    // DUT Outputs
    logic [31:0] mem_read_data;

    data_mem dut (
        .clk           (clk),
        .mem_write_en  (mem_write_en),
        .mem_read_en   (mem_read_en),
        .mem_addr      (mem_addr),
        .mem_write_data(mem_write_data),
        .mem_read_data (mem_read_data)
    );

    always #5 clk = ~clk;

    initial begin
        $display("=== TESTING DATA_MEM ===");
        clk = 0;
        mem_write_en = 0;
        mem_read_en = 0;
        mem_addr = 0;
        mem_write_data = 0;
        #10;

        // Write 0x12345678 to byte address 0x1000 (word index 1024)
        mem_write_en = 1;
        mem_addr = 32'h00001000;
        mem_write_data = 32'h12345678; #10;

        // Read back from address 0x1000
        mem_write_en = 0;
        mem_read_en = 1; #2;
        assert(mem_read_data == 32'h12345678) else $error("Test failed: mem_read_data = 0x%h (Expected: 0x12345678)", mem_read_data);
        $display("Read 0x1000: data = 0x%h (Expected: 12345678)", mem_read_data);

        // Read disable check
        mem_read_en = 0; #2;
        assert(mem_read_data == 32'h00000000) else $error("Test failed: mem_read_data = 0x%h (Expected: 0x00000000)", mem_read_data);
        $display("Read disabled: data = 0x%h (Expected: 00000000)", mem_read_data);

        $finish;
    end

endmodule
