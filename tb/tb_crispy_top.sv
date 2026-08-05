`timescale 1ns/1ps

module tb_crispy();

    // Declare Testbench Signals
    logic clk;
    logic rst_n;
    logic ebreak;
    logic [31:0] data_out; 

    // Instantiate the CPU (Device Under Test)
    crispy dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .data_out (data_out),
        .ebreak   (ebreak)
        // .debug_pc      (debug_pc),
        // .debug_alu_out (debug_alu_out)
    );

    // Generate the Clock (100 MHz -> 10ns period)
    always begin
        #5 clk = ~clk;
    end

    // Main Simulation Block
    initial begin
        int curr_node_idx;
        int prev_val;
        int is_sorted;
        int data_val;
        int next_ptr;

        // Setup waveform dumping (For Icarus Verilog / GTKWave)
        $dumpfile("build/crispy_top_dump.vcd");
        $dumpvars(0, tb_crispy);

        // Optional: Print the PC every cycle to the terminal to watch it run!
        // $monitor("Time: %0t | PC: %h", $time, dut.pc_out);

        // Load the machine code into the Instruction ROM
        $readmemh("build/program.hex", dut.u_rom.rom);

        // If you have a Data RAM that needs starting data, you can load it here too:
        // Load the array data into the Data RAM
        $readmemh("build/data.hex", dut.u_ram.ram);

        // Initialize signals
        clk = 0;
        rst_n = 0; // Hold processor in reset

        // Wait a few cycles, then release reset
        #15;
        rst_n = 1;

        // Let the CPU run for enough time to finish the sort
        // (May need to increase this number depending on array size)
        #50000; 

        // End simulation
        $display("Simulation Finished!");

        // Automatic Linked List Verification
        $display("======================================================");
        $display("               LINKED LIST VERIFICATION               ");
        $display("======================================================");
        // Read register x8 (head pointer address) and convert to word index
        curr_node_idx = dut.u_regfile.registers[8] >> 2; 
        prev_val = -1;
        is_sorted = 1;

        if (curr_node_idx == 0) begin
            $display(">>> ERROR: Head pointer (x8) is NULL (0x0)!");
        end else begin
            while (curr_node_idx != 0) begin
                data_val = dut.u_ram.ram[curr_node_idx + 1];
                next_ptr = dut.u_ram.ram[curr_node_idx + 2];
                
                $display("Node Word Index: 0x%03h | Data Payload: 0x%04h", curr_node_idx, data_val);
                
                if (data_val < prev_val) begin
                    is_sorted = 0;
                end
                
                prev_val = data_val;
                curr_node_idx = next_ptr >> 2; // Convert byte address pointer to word index
            end

            if (is_sorted) begin
                $display("----------------------------------------");
                $display(">>> TEST PASSED: Linked list is sorted!");
                $display("----------------------------------------");
            end else begin
                $display("----------------------------------------");
                $display(">>> TEST FAILED: Nodes out of order!");
                $display("----------------------------------------");
            end
        end

        // Dump the final state of the RAM to a hex file!
        $writememh("build/final_ram.hex", dut.u_ram.ram);

        $finish;
    end

endmodule
