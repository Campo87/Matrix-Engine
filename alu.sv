// -----------------------------------------------------------------------------
// FILE NAME : alu.v
// AUTHOR : JAMES STARKS
// -----------------------------------------------------------------------------
// DESCRIPTION
// Operations multiplication, scalar multiplication, subtraction, addition, and
// transposition.
//
// OPCODE | INSTRUCTION
// ---------------------------------------
// 0      | NOP
// 1      | Matrix multiplication
// 2      | Matrix scalar multipliation
// 3      | Matrix subtraction
// 4      | Matrix addition
// 5      | Matrix transposition
// 6      | Addition
// 7      | Subtraction
// 8      | Right shift
// 9      | Left shift
// A      | Rotate right
// B      | Rotate left
// C      | Greater than
// D      | Less than
// E      | Equal
// F      | Logic XOR
//
// -----------------------------------------------------------------------------
module alu (
    input [255:0] matrix_a,
    input [255:0] matrix_b,
    input [3:0] op,
    input rst,
    input clk,
    output reg [255:0] matrix_c
);

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

  reg [15:0] reg_ma[3:0][3:0];
  reg [15:0] reg_mb[3:0][3:0];
  reg [15:0] reg_mc[3:0][3:0];

  // Translate matrix from 1D to 2D
  always_comb begin : unroll_roll_matrices
    for (int i = 0; i < 4; i++) begin
      for (int j = 0; j < 4; j++) begin
        // 1D to 2D input matrices
        reg_ma[i][j] = matrix_a[(i * 4 + j) * 16 +: 16];
        reg_mb[i][j] = matrix_b[(i * 4 + j) * 16 +: 16];
        // 2D to 1D ans for output
        matrix_c[(i * 4 + j) * 16 +: 16] = reg_mc[i][j];
      end
    end
  end

  // ALU mux
  always_comb begin : alu
    case (op)
      NOP: begin
        for (int i = 0; i < 4; i++) begin
          for (int j = 0; j < 4; j++) begin
            reg_mc[i][j] = '0;
          end
        end
      end
      MMULT: begin
        for (int i = 0; i < 4; i++) begin
          for (int j = 0; j < 4; j++) begin
            for (int k = 0; k < 4; k++) begin
              reg_mc[i][j] = reg_mc[i][j] + (reg_ma[i][k] * reg_mb[k][j]);
            end
          end
        end
      end
      MSCALAR: begin
        for (int i = 0; i < 4; i++) begin
          for (int j = 0; j < 4; j++) begin
            reg_mc[i][j] = reg_ma[i][j] * reg_mb[0][0];
          end
        end
      end
      MADD: begin
        for (int i = 0; i < 4; i++) begin
          for (int j = 0; j < 4; j++) begin
            reg_mc[i][j] = reg_ma[i][j] + reg_mb[i][j];
          end
        end
      end
      MSUB: begin
        for (int i = 0; i < 4; i++) begin
          for (int j = 0; j < 4; j++) begin
            reg_mc[i][j] = reg_ma[i][j] - reg_mb[i][j];
          end
        end
      end
      MTRANS: begin
        for (int i = 0; i < 4; i++) begin
          for (int j = 0; j < 4; j++) begin
            reg_mc[i][j] = reg_ma[j][i];
          end
        end
      end
      ADD: begin
        for (int i = 0; i < 4; i++) begin
          for (int j = 0; j < 4; j++) begin
            reg_mc[i][j] = reg_ma[i][j] + reg_mb[0][0];
          end
        end
      end
      SUB: begin
        for (int i = 0; i < 4; i++) begin
          for (int j = 0; j < 4; j++) begin
            reg_mc[i][j] = reg_ma[i][j] - reg_mb[0][0];
          end
        end
      end
      XOR: begin
        for (int i = 0; i < 4; i++) begin
          for (int j = 0; j < 4; j++) begin
            reg_mc[i][j] = reg_ma[i][j] ^ reg_mb[0][0];
          end
        end
      end
      ARS: begin
        for (int i = 0; i < 4; i++) begin
          for (int j = 0; j < 4; j++) begin
            reg_mc[i][j] = reg_ma[i][j] >>> 1;
          end
        end
      end
      ALS: begin
        for (int i = 0; i < 4; i++) begin
          for (int j = 0; j < 4; j++) begin
            reg_mc[i][j] = reg_ma[i][j] <<< 1;
          end
        end
      end
      LRS: begin
        for (int i = 0; i < 4; i++) begin
          for (int j = 0; j < 4; j++) begin
            reg_mc[i][j] = reg_ma[i][j] >> 1;
          end
        end
      end
      LLS: begin
        for (int i = 0; i < 4; i++) begin
          for (int j = 0; j < 4; j++) begin
            reg_mc[i][j] = reg_ma[i][j] << 1;
          end
        end
      end
      GT: begin
        for (int i = 0; i < 4; i++) begin
          for (int j = 0; j < 4; j++) begin
            reg_mc[i][j] = (reg_ma[i][j] > reg_mb[i][j]) ? 'b1 : 'b0;
          end
        end
      end
      LT: begin
        for (int i = 0; i < 4; i++) begin
          for (int j = 0; j < 4; j++) begin
            reg_mc[i][j] = (reg_ma[i][j] < reg_mb[i][j]) ? 'b1 : 'b0;
          end
        end
      end
      EQ: begin
        for (int i = 0; i < 4; i++) begin
          for (int j = 0; j < 4; j++) begin
            reg_mc[i][j] = (reg_ma[i][j] == reg_mb[i][j]) ? 'b1 : 'b0;
          end
        end
      end
      default: begin
        for (int i = 0; i < 4; i++) begin
          for (int j = 0; j < 4; j++) begin
            reg_mc[i][j] = '0;
          end
        end
      end
    endcase
  end

endmodule
