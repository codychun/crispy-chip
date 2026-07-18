`include "riscv_pkg.sv"

module crispy(
    input  logic clk,
    input  logic rst_n,

    output logic [31:0] data_out,
    output logic ebreak
);

    // PC
    logic [31:0] pc_out;
    logic [31:0] pc_next;
    logic [31:0] pc_plus_4;
    logic [31:0] pc_branch_target;
    logic [1:0]  pc_sel;

    // Imm Gen
    logic [31:0] imm;

    // Decoder
    logic [6:0] opcode;
    logic [4:0] rd_addr;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [2:0] funct3;
    logic [6:0] funct7;

    // Regfile
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] rd_data;
    logic        reg_write_en;
    logic        mem_to_reg_sel;

    // ALU
    riscv_pkg::alu_op_t alu_op;
    logic [31:0]        alu_b;
    logic [31:0]        alu_out;
    logic               alu_src_sel;
    logic               zero;
    logic               less_than;

    // Instruction Memory ROM
    logic [31:0] instr_data;

    // Data Memory RAM
    logic [31:0] mem_read_data;
    logic        mem_write_en;
    logic        mem_read_en;

    // PC Source
    assign pc_plus_4        = pc_out + 32'd4;  // PC Adder (+4)
    assign pc_branch_target = pc_out + imm;    // Branch Adder (+Imm)

    // PC MUX
    always_comb begin
        pc_next = pc_plus_4;

        case (pc_sel)
            2'b00: pc_next = pc_plus_4;
            2'b01: pc_next = pc_branch_target;
            // 2'b10: // Future JALR support
            default: ;
        endcase
    end

    // ALU MUX
    always_comb begin
        alu_b = 32'b0; // Default: immediate (32'b0)

        case (alu_src_sel)
            1'b0: alu_b = rs2_data; // regfile data out
            1'b1: alu_b = imm;      // immediate
        endcase
    end 

    // Mem to Regfile MUX
    always_comb begin
        rd_data = alu_out;

        case (mem_to_reg_sel) 
            1'b0: rd_data = alu_out;
            1'b1: rd_data = mem_read_data;
        endcase
    end

    // Dummy output pin: ALU result
    assign data_out = alu_out;

    // Instantiate modules
    pc u_pc (
        .clk     (clk),
        .rst_n   (rst_n),
        .pc_next (pc_next),
        .pc_out  (pc_out)
    );

    imm_gen u_imm_gen (
        .instr (instr_data),
        .imm   (imm)
    );

    decoder u_decoder (
        .instr  (instr_data),
        .opcode (opcode),
        .rd     (rd_addr),
        .rs1    (rs1_addr),
        .rs2    (rs2_addr),
        .funct3 (funct3),
        .funct7 (funct7)
    );

    controller u_controller (
        .opcode         (riscv_pkg::opcode_t'(opcode)),
        .funct3         (riscv_pkg::alu_f3_t'(funct3)),
        .funct7_5       (funct7[5]),
        .alu_op         (alu_op),
        .reg_write_en   (reg_write_en),
        .alu_src_sel    (alu_src_sel),
        .mem_write_en   (mem_write_en),
        .mem_read_en    (mem_read_en),
        .mem_to_reg_sel (mem_to_reg_sel),
        .ebreak         (ebreak)
    );

    branch_ctl u_branch_ctl (
        .opcode    (riscv_pkg::opcode_t'(opcode)),
        .funct3    (riscv_pkg::br_f3_t'(funct3)),
        .less_than (less_than),
        .zero      (zero),
        .pc_sel    (pc_sel)
    );

    instr_mem u_rom (
        .instr_addr (pc_out),
        .instr_data (instr_data)
    );

    regfile u_regfile (
        .clk          (clk),
        .reg_write_en (reg_write_en),
        .rs1_addr     (rs1_addr),
        .rs2_addr     (rs2_addr),
        .rd_addr      (rd_addr),
        .rd_data      (rd_data),
        .rs1_data     (rs1_data),
        .rs2_data     (rs2_data)
    );

    alu u_alu (
        .a         (rs1_data),
        .b         (alu_b),
        .alu_op    (alu_op),
        .result    (alu_out),
        .zero      (zero),
        .less_than (less_than)
    );

    data_mem u_ram (
        .clk            (clk),
        .mem_write_en   (mem_write_en),
        .mem_read_en    (mem_read_en),
        .mem_addr       (alu_out),
        .mem_write_data (rs2_data),
        .mem_read_data  (mem_read_data)
    );

endmodule
