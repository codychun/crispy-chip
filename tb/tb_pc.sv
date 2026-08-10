`timescale 1ns/1ps

module tb_pc();

    // Testbench Inputs
    logic        clk;
    logic        rst_n;
    logic [31:0] pc_next;

    // DUT Outputs
    logic [31:0] pc_out;

    pc dut (
        .clk    (clk),
        .rst_n  (rst_n),
        .pc_next(pc_next),
        .pc_out (pc_out)
    );

    always #5 clk = ~clk;

    initial begin
        $display("=== TESTING PC REGISTER ===");
        clk = 0;
        rst_n = 0;
        pc_next = 32'h00000004;

        // Verify reset holds PC at 0
        #12;
        assert(pc_out == 32'h00000000) else $error("PC did not reset to 0");
        $display("Reset active: pc_out = 0x%h (Expected: 0x0)", pc_out);

        // Release reset
        rst_n = 1; #10;
        assert(pc_out == 32'h00000004) else $error("PC did not update to pc_next");
        $display("Clock cycle 1: pc_out = 0x%h (Expected: 0x4)", pc_out);

        pc_next = 32'h00000008; #10;
        assert(pc_out == 32'h00000008) else $error("PC did not update to pc_next");
        $display("Clock cycle 2: pc_out = 0x%h (Expected: 0x8)", pc_out);

        // Assert reset again
        rst_n = 0; #12;
        #12;
        assert(pc_out == 32'h00000000) else $error("PC did not reset to 0");
        $display("Reset active: pc_out = 0x%h (Expected: 0x0)", pc_out);

        $finish;
    end

endmodule
