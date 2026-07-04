module decoder(
    input logic [31:0] instr,

    // Instruction Fields
    output logic [6:0]  opcode,
    output logic [4:0]  rd,
    output logic [2:0]  func3,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [6:0]  func7
); 
    // Unpack all possible fields simultaneously
    // Faster execution w/ no hardware cost (just wires)
    assign opcode = instr[6:0];
    assign rd = instr[11:7];
    assign func3 = instr[14:12];
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign func7 = instr[31:25];

endmodule