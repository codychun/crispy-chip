module data_mem(
    input  logic        clk,
    input  logic        mem_write_en,
    input  logic        mem_read_en,
    input  logic [31:0] mem_addr,
    input  logic [31:0] mem_write_data,

    output logic [31:0] mem_read_data
);

    // Allocate RAM space
        // Byte Addressable: Max - 2^32 bytes, 2^30 words
        // Limited to 1024 words for simulation
    logic [31:0] ram [0:8191];

    // Word-aligned asynchronous read
    assign mem_read_data = (mem_read_en) ? ram[mem_addr[31:2]] : 32'b0;

    // Synchronous write
    always_ff @(posedge clk) begin
        if (mem_write_en) begin
            ram[mem_addr[31:2]] <= mem_write_data;
        end
    end

endmodule
