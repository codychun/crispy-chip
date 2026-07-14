`include "riscv_pkg.sv"

module pc(
    input  logic        clk,
    input  logic        rst_n,   // Active low
    input  logic [31:0] pc_next, // Next address from PC MUX

    output logic [31:0] pc_out   // Pointer to current instruction address
);

    // PC Register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out <= 32'b0;     // Start of instruction memory
        end else begin
            pc_out <= pc_next;
        end
    end

endmodule
