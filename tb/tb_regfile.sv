`timescale 1ns/1ps

module tb_regfile();

    // Testbench Inputs
    logic        clk;
    logic        rst_n;
    logic        reg_write_en;
    logic [4:0]  rs1_addr, rs2_addr, rd_addr;
    logic [31:0] rd_data;

    // DUT Outputs
    logic [31:0] rs1_data, rs2_data;

    regfile dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .reg_write_en (reg_write_en),
        .rs1_addr     (rs1_addr),
        .rs2_addr     (rs2_addr),
        .rd_addr      (rd_addr),
        .rd_data      (rd_data),
        .rs1_data     (rs1_data),
        .rs2_data     (rs2_data)
    );

    always #5 clk = ~clk;

    initial begin
        $display("=== TESTING REGFILE ===");
        clk = 0;
        rst_n = 0;
        reg_write_en = 0;
        rs1_addr = 0; rs2_addr = 0; rd_addr = 0; rd_data = 0;
        #10;

        // Write 0xDEADBEEF to register x5
        reg_write_en = 1;
        rd_addr = 5'd5;
        rd_data = 32'hDEADBEEF; #10;

        // Read back from x5 on rs1 (Reset still active, should read 0x0)
        reg_write_en = 0;
        rs1_addr = 5'd5; #2;
        assert(rs1_data == 32'h00000000) else $error("Test failed: Expected rs1_data to be 0x00000000, got 0x%h", rs1_data);
        $display("Read x5: rs1_data = 0x%h (Expected: 00000000)", rs1_data);

        // Deassert reset and read back from x5 (Should read 0xDEADBEEF)
        rst_n = 1; #10;

        // Write 0xDEADBEEF to register x5
        reg_write_en = 1;
        rd_addr = 5'd5;
        rd_data = 32'hDEADBEEF; #10;
        assert(rs1_data == 32'hDEADBEEF) else $error("Test failed: Expected rs1_data to be 0xDEADBEEF, got 0x%h", rs1_data);
        $display("Read x5: rs1_data = 0x%h (Expected: DEADBEEF)", rs1_data);

        // Attempt write to x0 (Must stay 0x0)
        reg_write_en = 1;
        rd_addr = 5'd0;
        rd_data = 32'hCAFECAFE; #10;

        reg_write_en = 0;
        rs1_addr = 5'd0; #2;
        assert(rs1_data == 32'h00000000) else $error("Test failed: Expected rs1_data to be 0x00000000, got 0x%h", rs1_data);
        $display("Read x0: rs1_data = 0x%h (Expected: 00000000)", rs1_data);

        $finish;
    end

endmodule
