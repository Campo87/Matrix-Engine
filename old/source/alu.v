///////////////////////////////////////////////////////////////////////////////
// This module handles data exchanges and arithmetic operations.
//  Author: James Starks
//  State walkthrough...
//  wait_en: ALU will remain in this state until en goes high.
//  move_reg_a: Load Mem[S1]=>Reg[A].
//  move_reg_b: Load Mem[S2/Imm]=>Reg[B].
//  load_s1: Roll datain into local matrix s1.
//  load_s2: Roll datain into local matrix s2, or if opcode is scalar
//           an identity matrix is setup with the diag equaling the imm.
//  start: Start calculating based on the opcode and store results in 
//         local destination matrix.
//  store_dest: Unroll dest matrix onto the dataout line.
//  clean_up: House cleaning, also let the execution engine know alu 
//            calculations are done.
///////////////////////////////////////////////////////////////////////////////
module alu(done, r_rw, m_rw, r_en, m_en, r_address, m_address, datain, dataout, en, stop, rst, clk, op, s1, dest, s2, curr_state);
    // Signal completion
    output reg done;
    // Register & memory controls
    output reg r_rw, m_rw, r_en, m_en;
    
    // Addressing for memory and register memory modules
    output reg [1:0] r_address;
    output reg [2:0] m_address;

    // Incoming matrix data line
    output reg [255:0] dataout;
    // Outbound matrix data line
    input [255:0] datain;

    // ALU specific control inputs
    input stop, en, rst, clk;

    // Decoded instruction control inputs from exe engine
    input [2:0] op;
    input [3:0] s1, dest;
    input [7:0] s2;

    // (4x4x16bit) Registers for holding matrix data from memory module
    reg [15:0] matrix_s1 [3:0][3:0];
    reg [15:0] matrix_s2 [3:0][3:0];
    reg [15:0] matrix_dest [3:0][3:0];

    // These are used for for-loop
    integer i, j, k;

    // Register address referencing
    parameter A = 2'b00;
    parameter B = 2'b01;
    parameter D = 2'b11;

    // Opcode referencing
    parameter add =       3'b001;
    parameter sub =       3'b010;
    parameter scalar =    3'b011;
    parameter multiply =  3'b100;
    parameter transpose = 3'b101;

    // Holds current state of the ALU
    output reg [2:0] curr_state;

    // State referencing
    parameter wait_en    = 3'b000;
    parameter move_reg_a = 3'b001;
    parameter move_reg_b = 3'b010;
    parameter load_s1    = 3'b011;
    parameter load_s2    = 3'b100;
    parameter start      = 3'b101;
    parameter store_dest = 3'b110;
    parameter clean_up   = 3'b111;

    // Enter block at clk or rst positive edge
    always@(posedge clk, posedge rst) begin
        // Reset the ALU, simply put the current state to wait_en
        if(rst) begin
            curr_state = wait_en;
        end else if(stop) begin
            curr_state = clean_up;
        // Check case, see if ALU state is ready to continue
        end else begin
            case(curr_state)

                // Wait for enable signal from exe engine to start
                wait_en: begin
                    if(en) begin
                        curr_state = move_reg_a;
                    end
                    done = 0;
                end

                // Move matrix data from memory to register location A
                move_reg_a: begin
                    m_address = s1; r_address = A;
                    m_en = 1; m_rw = 1;
                    r_en = 1; r_rw = 0;
                    
                    curr_state =  move_reg_b;
                end

                // Move matrix data from memory to register location B
                move_reg_b: begin
                    m_address = s2; r_address = B;

                    curr_state = load_s1;
                end

                // Load matrix data from register location A into local 
                // matrix_s1
                load_s1: begin
                    r_address = A;
                    r_en = 1; r_rw = 0;

                    matrix_s1[0][0] = datain[15:0];
                    matrix_s1[0][1] = datain[31:16];
                    matrix_s1[0][2] = datain[47:32];
                    matrix_s1[0][3] = datain[63:48];
                    matrix_s1[1][0] = datain[79:64];
                    matrix_s1[1][1] = datain[95:80];
                    matrix_s1[1][2] = datain[111:96];
                    matrix_s1[1][3] = datain[127:112];
                    matrix_s1[2][0] = datain[143:128];
                    matrix_s1[2][1] = datain[159:144];
                    matrix_s1[2][2] = datain[175:160];
                    matrix_s1[2][3] = datain[191:176];
                    matrix_s1[3][0] = datain[207:192];
                    matrix_s1[3][1] = datain[223:208];
                    matrix_s1[3][2] = datain[239:224];
                    matrix_s1[3][3] = datain[255:240];

                    curr_state = load_s2;
                end

                // Load matrix data from register location B into local 
                // matrix_s2. If scalar op code is observed, setup s2
                // to be an identity matrix with the imm(s2) value on 
                // the diag.
                load_s2: begin
                    r_address = B;
                    
                    // Zero out matrix_s2
                    if (op == scalar) begin
                        for(i=0;i<4;i=i+1)
                            for(j=0;j<4;j=j+1)
                                matrix_s2[i][j] = 0;
                        // Set values on the diag equal to the value
                        // in s2, since this is a scalar operation.
                        matrix_s2[0][0] = s2;
                        matrix_s2[1][1] = s2;
                        matrix_s2[2][2] = s2;
                        matrix_s2[3][3] = s2;
                    end else begin
                        // Roll matrix data into matrix_s2
                        matrix_s2[0][0] = datain[15:0];
                        matrix_s2[0][1] = datain[31:16];
                        matrix_s2[0][2] = datain[47:32];
                        matrix_s2[0][3] = datain[63:48];
                        matrix_s2[1][0] = datain[79:64];
                        matrix_s2[1][1] = datain[95:80];
                        matrix_s2[1][2] = datain[111:96];
                        matrix_s2[1][3] = datain[127:112];
                        matrix_s2[2][0] = datain[143:128];
                        matrix_s2[2][1] = datain[159:144];
                        matrix_s2[2][2] = datain[175:160];
                        matrix_s2[2][3] = datain[191:176];
                        matrix_s2[3][0] = datain[207:192];
                        matrix_s2[3][1] = datain[223:208];
                        matrix_s2[3][2] = datain[239:224];
                        matrix_s2[3][3] = datain[255:240];
                    end
                    
                    curr_state = start;
                end

                // Begin math
                start: begin
                    // Clean up control lines
                    m_address = 256'bz; r_address = 256'bz;
                    m_en = 0; m_rw = 0;
                    r_en = 0; r_rw = 0;

                    // Zero out dest matrix...matrix multiplaction algorithm
                    // requires values initially equal to zero.
                    for(i=0;i<4;i=i+1)
                        for(j=0;j<4;j=j+1)
                            matrix_dest[i][j] = 0;

                    // Select operation
                    case(op)
                        // matrix_s1 + matrix_s2 = matrix_dest
                        add: begin
                            for(i=0;i<4;i=i+1)
                                for(j=0;j<4;j=j+1)
                                    matrix_dest[i][j] = matrix_s1[i][j] + matrix_s2[i][j];
                        end

                        // matrix_s2 - matrix_s1 = matrix_dest
                        sub: begin
                            for(i=0;i<4;i=i+1)
                                for(j=0;j<4;j=j+1)
                                    matrix_dest[i][j] = matrix_s1[i][j] - matrix_s2[i][j];
                        end

                        // matrix_s1 * matrix_s2 = matrix_dest
                        // matrix scaling is achieved by multiplying matrix_s1 by
                        // an identity matrix w/ scalar value on the diag.
                        scalar, multiply: begin
                            for(i=0;i<4;i=i+1)
                                for(j=0;j<4;j=j+1)
                                    for(k=0;k<4;k=k+1)
                                        matrix_dest[i][j] = matrix_dest[i][j] + (matrix_s1[i][k]*matrix_s2[k][j]);
                        end
                        
                        // Transpose(matrix_s1) = matrix_dest
                        transpose: begin
                            for(i=0;i<4;i=i+1)
                                for(j=0;j<4;j=j+1)
                                    matrix_dest[j][i] = matrix_s1[i][j];
                        end
                    endcase

                    curr_state = store_dest;
                end
                
                // Unroll matrix data from local dest matrix onto dataout lines
                store_dest: begin
                    m_address = dest;
                    m_en = 1; m_rw = 0;
                    r_en = 1; r_rw = 1;

                    // Unroll matrix_dest onto the dataout lines
                    dataout[15:0]    = matrix_dest[0][0];
                    dataout[31:16]   = matrix_dest[0][1];
                    dataout[47:32]   = matrix_dest[0][2];
                    dataout[63:48]   = matrix_dest[0][3];
                    dataout[79:64]   = matrix_dest[1][0];
                    dataout[95:80]   = matrix_dest[1][1];
                    dataout[111:96]  = matrix_dest[1][2];
                    dataout[127:112] = matrix_dest[1][3];
                    dataout[143:128] = matrix_dest[2][0];
                    dataout[159:144] = matrix_dest[2][1];
                    dataout[175:160] = matrix_dest[2][2];
                    dataout[191:176] = matrix_dest[2][3];
                    dataout[207:192] = matrix_dest[3][0];
                    dataout[223:208] = matrix_dest[3][1];
                    dataout[239:224] = matrix_dest[3][2];
                    dataout[255:240] = matrix_dest[3][3];

                    curr_state = clean_up;
                end

                // House cleaning, and notify exe engine calculations are complete
                clean_up: begin
                    dataout = 256'bz; r_address = 2'b0; m_address = 3'b0;
                    r_en = 0; m_en = 0; r_rw = 0; m_rw = 0;
                    done = 1;

                    curr_state = wait_en;
                end
            endcase
        end
    end
endmodule
