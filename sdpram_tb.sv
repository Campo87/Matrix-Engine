// -----------------------------------------------------------------------------
// FILE NAME : sdpram_tb.v
// AUTHOR : JAMES STARKS
// -----------------------------------------------------------------------------
// DESCRIPTION
// Test bench for the synchronous dual-port random access memory module. Test
// simultaneous read and simultaneous write on port A and B.
//
// -----------------------------------------------------------------------------
module sdpram_tb ();

  reg [255:0] d_a, d_b;
  reg [4:0] addr_a, addr_b;
  reg wen_a, wen_b, clk;
  wire [255:0] q_a, q_b;

  localparam T = 10;

  sdpram DUT (
      .d_a(d_a),
      .d_b(d_b),
      .addr_a(addr_a),
      .addr_b(addr_b),
      .wen_a(wen_a),
      .wen_b(wen_b),
      .clk(clk),
      .q_a(q_a),
      .q_b(q_b)
  );

  initial begin
    d_a = 'd0;
    d_b = 'd0;
    addr_a = 'd0;
    addr_b = 'd0;
    wen_a = 'b0;
    wen_b = 'b0;
    clk = 'b0;
    forever #(T / 2) clk = ~clk;
  end

  initial begin
    $monitor("A: wen %b addr %d d %d q %d clk %b time: %d\n", wen_a, addr_a, d_a, q_a, clk, $time);
    $monitor("B: wen %b addr %d d %d q %d clk %b time: %d\n", wen_b, addr_b, d_b, q_b, clk, $time);

    // Writing
    #T wen_a = 'b1;
    wen_b = 'b1;
    addr_a = 'd1;
    addr_b = 'd3;
    d_a = 'd1337;
    d_b = 'd2022;

    #T addr_a = 'd2;
    addr_b = 'd4;
    d_a = 'd1338;
    d_b = 'd2023;

    // Transition
    #T wen_a = 'b0;
    wen_b  = 'b0;
    addr_a = 'b0;
    addr_b = 'b0;
    d_a = 'd0;
    d_b = 'd0;

    // Reading
    #T addr_a = 'd1;
    addr_b = 'd3;

    #T addr_a = 'd2;
    addr_b = 'd4;

    // End
    #T addr_a = 'd0;
    addr_b = 'd0;

  end

endmodule
