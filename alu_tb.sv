// -----------------------------------------------------------------------------
// FILE NAME : alu_tb.v
// AUTHOR : JAMES STARKS
// -----------------------------------------------------------------------------
// DESCRIPTION
// Test bench for the ALU module
//
// -----------------------------------------------------------------------------
module alu_tb ();

  reg [255:0] matrix_a, matrix_b, matrix_c;
  reg [3:0] op;
  reg rst, clk;

  reg [15:0] reg_ma [3:0][3:0];
  reg [15:0] reg_mb [3:0][3:0];
  reg [15:0] reg_mc [3:0][3:0];

  localparam T = 10;

  enum {
    NOP,      // 0
    MMULT,    // 1
    MSCALAR,  // 2
    MADD,     // 3
    MSUB,     // 4
    MTRANS,   // 5
    ADD,      // 6
    SUB,      // 7
    XOR,      // 8
    ARS,      // 9
    ALS,      // A
    LRS,      // B
    LLS,      // C
    GT,       // D
    LT,       // E
    EQ        // F
  } opcode;

  alu dut (
      .matrix_a(matrix_a),
      .matrix_b(matrix_b),
      .op(op),
      .clk(clk),
      .rst(rst),
      .matrix_c(matrix_c)
  );

  // Translate 2D regs to 1D vectors
  // Useful for easily assigning values in the matrix
  always_comb begin : unroll
    for (int i = 0; i < 4; i++) begin
      for (int j = 0; j < 4; j++) begin
        // 2D to 1D
        matrix_a[(i * 4 + j) * 16 +: 16] = reg_ma[i][j];
        matrix_b[(i * 4 + j) * 16 +: 16] = reg_mb[i][j];
        // 1D to 2D
        reg_mc[i][j] = matrix_c[(i * 4 + j) * 16 +: 16];
      end
    end
  end

  // Intialize variables and clk
  initial begin
    for (int i = 0; i < 4; i++) begin
      for (int j = 0; j < 4; j++) begin
        reg_ma[i][j] = 'd0;
        reg_mb[i][j] = 'd0;
        reg_mc[i][j] = 'd0;
      end
    end
    op  = NOP;
    rst = 'b0;
    clk = 'b0;
    forever #(T / 2) clk = ~clk;
  end

  initial begin
    #T;
    for (int i = 0; i < 4; i++) begin
      for (int j = 0; j < 4; j++) begin
        reg_ma[i][j] = j;
        reg_mb[i][j] = j;
      end
    end

    #T op = MMULT;
    #T op = MADD;
    #T op = MSUB;
    #T op = MTRANS;
    #T op = MSCALAR;
    reg_mb[0][0] = 'd256;  // Set scalar
    #T op = ADD;
    #T op = SUB;
    #T op = XOR;
    #T op = ARS;
    #T op = ALS;
    #T op = LRS;
    #T op = LLS;
    #T op = GT;
    #T op = LT;
    #T op = EQ;

    // End
    #T op = NOP;

  end

endmodule
