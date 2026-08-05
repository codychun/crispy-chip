module instr_mem(
    input  logic [31:0] instr_addr,
    
    output logic [31:0] instr_data
);

    // Allocate ROM instruction memory
        // Byte-addressable: Max - 2^32 bytes, 2^30 words
        // Limited to 1024 words for simulation
    logic [31:0] rom [0:1023];

    // Word-aligned asynchronous read
        // Bottom two bits are byte offset
    assign instr_data = rom[instr_addr[31:2]];

    // Load assembly binary (hex) file
    // initial begin
    //     $readmemh("program.hex", rom);
    // end

endmodule
