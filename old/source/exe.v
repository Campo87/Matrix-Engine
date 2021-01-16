///////////////////////////////////////////////////////////////////////////////
// This module handels instruction decoding and alu controlling.
// Author: James Starks
// State walkthrough...
// decode: Parse instruction and pass it out to the ALU, along with signaling
//         the ALU to begin.
// if_done: Look until the ALU signals it's done calculating
// stop_loop: Brick instruction received, so loop endlessly until sim ended
//            or execution engine is reset.
///////////////////////////////////////////////////////////////////////////////
module exe(op, s1, dest, s2, en_alu, stop, done, rst, clk, curr_state, pc);
    // Decoded instruction outbound to the execution engine
    output reg [2:0] op;
    output reg [3:0] s1, dest;
    output reg [7:0] s2;

    // Enable ALU control line
    output reg en_alu, stop;

    // Exe engine specific controls
    input done, rst, clk;

    // Program counter for rom
    output reg [3:0]  pc;
    // Read-only-memory for the instructions
    reg [18:0] rom [8:0];

    // Holds current state of the exe engine
    output reg [1:0] curr_state;

    // State referencing
    parameter decode  = 2'b00;
    parameter if_done = 2'b01;
    parameter stop_loop = 2'b11;

    // All zeroes will soft brick the exe engine
    parameter brick = 19'b0;

    initial begin
        /*  Instruction building template
            +-----------------------+
            |op | s1 | s2/imm  |dest|
            +-----------------------+
            |000|0000|0000_0000|0000|
             001 0000 0000_0001 0010
             010 0001 0000_0000 0011
             101 0010 0000_0000 0100 
             011 0100 0000_0111 0101
             100 0101 0000_0100 0110
            +-----------------------+
        */
        // Initialize read only memory that will be used for intructions 
        rom[0] = 19'b0010000000000010010;
        rom[1] = 19'b0100000000000010011;
        rom[2] = 19'b1010010000000000100;
        rom[3] = 19'b0110100000001110101;
        rom[4] = 19'b1000101000001000110;
        rom[5] = 19'b0; //stop
    end

    // Enter block at clk or rst positive edge
    always@(posedge clk, posedge rst) begin
        // Reset the exe, simply put the current state to start decoding
        if(rst) begin
            curr_state = decode;
            pc = 4'b0;
            stop = 0;
        end else begin
            // Main state machine
            case (curr_state)
                decode: begin
                    // An instruction is all zeroes, enter a stop loop
                    if (rom[pc] == brick) begin
                        curr_state = stop_loop;
                        stop = 1;
                        $display("Bricked"); // Brick locks up the statemachine, reset to 
                    end else begin
                        // Parse instruction and pass data to ALU
                        op     = rom[pc][18:16];
                        s1     = rom[pc][15:12];
                        s2     = rom[pc][11:4];
                        dest   = rom[pc][3:0];
                        en_alu = 1;
                        
                        curr_state = if_done;
                    end
                end
                // This state waits for the ALU to signal calculations are complete before continuing.
                if_done: begin
                    en_alu = 0;

                    if (done) begin
                        en_alu = 0;
                        curr_state = decode;
                        pc = pc + 1;
                    end else begin
                        curr_state = if_done;
                    end
                end
                // The state machine can't leave this state unless the module is reset.
                stop_loop: begin
                    op     = 3'bz; s1   = 4'bz; 
                    s2     = 8'bz; dest = 4'bz;
                    en_alu = 1'bz; stop = 1;
                    curr_state = stop_loop;
                end
            endcase
        end
    end
endmodule
