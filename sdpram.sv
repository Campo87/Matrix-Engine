// -----------------------------------------------------------------------------
// FILE NAME : sdpram.v
// AUTHOR : JAMES STARKS
// -----------------------------------------------------------------------------
// DESCRIPTION
// Synchronous dual-port random access memory. This memory module contains 16
// 256-bit registers.
//
// Port A
// d_a:     Input wires for port a
// q_a:     Output wires for port a
// addr_a:   Address lookup for port a
// wen_a:   Enable writing from port a when 1, reading when 0
//
// Port B
// d_b:     Input wires for port b
// q_b:     Output wires for port b
// addr_b:   Address lookup for port b
// wen_b:   Enable writing from port b when 1, reading when 0
//
// -----------------------------------------------------------------------------
module sdpram (
    input [255:0] d_a,
    input [255:0] d_b,
    input [4:0] addr_a,
    input [4:0] addr_b,
    input wen_a,
    input wen_b,
    input clk,
    output reg [255:0] q_a,
    output reg [255:0] q_b
);


  // Random Access Memory
  reg [255:0] ram [15:0];

  // Port A
  always_ff @(posedge clk) begin
    if (wen_a == 'b1) begin
      ram[addr_a] <= d_a;
      q_a <= d_a;
    end else begin
      q_a <= ram[addr_a];
    end
  end

  // Port B
  always_ff @(posedge clk) begin
    if (wen_b == 'b1) begin
      ram[addr_b] <= d_b;
      q_b <= d_b;
    end else begin
      q_b <= ram[addr_b];
    end
  end

endmodule
