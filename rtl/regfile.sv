module regfile (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        reg_write_en,
    input  logic [4:0]  rs1_addr,
    input  logic [4:0]  rs2_addr,
    input  logic [4:0]  rd_addr,
    input  logic [31:0] rd_data,

    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);
    // 32 registers, each 32 bits wide
    logic [31:0] registers[31:0];

    // Connect rs1/rs2 data out to internal registers
    // Default register 0: 32'b0
    assign rs1_data = (rs1_addr == 5'b0) ? 32'b0 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 5'b0) ? 32'b0 : registers[rs2_addr];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers to 0
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'b0;
            end
        end else if (reg_write_en && (rd_addr != 5'b0)) begin
            registers[rd_addr] <= rd_data;
        end
    end

endmodule
