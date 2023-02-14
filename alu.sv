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
module alu(
    input   [255:0] matrixa,
    input   [255:0] matrixb,
    input           op,
    input           clk,
    input           rst,
    output  [255:0] matrixc
);
    parameter nop     = 4'h0;
    parameter m_mult  = 4'h1;
    parameter m_scale = 4'h2;
    parameter m_sub   = 4'h3;
    parameter m_add   = 4'h4;
    parameter m_trans = 4'h5;
    parameter add     = 4'h6;
    parameter sub     = 4'h7;
    parameter rshift  = 4'h8;
    parameter lshift  = 4'h9;
    parameter rrotate = 4'hA;
    parameter lrotate = 4'hB;
    parameter gt      = 4'hC;
    parameter lt      = 4'hD;
    parameter eq      = 4'hE;
    parameter lxor    = 4'hF;

    integer i, j, k;
    reg  [255:0] ans;


endmodule
