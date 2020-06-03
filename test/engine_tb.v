///////////////////////////////////////////////////////////////////////////////
// This file converts an input binary number into an output which can get sent
// to a 7-Segment LED.  7-Segment LEDs have the ability to display all decimal
// numbers 0-9 as well as hex digits A, B, C, D, E and F.  The input to this
// module is a 4-bit binary number.  This module will properly drive the
// individual segments of a 7-Segment LED in order to display the digit.
// Hex encoding table can be viewed at:
// http://en.wikipedia.org/wiki/Seven-segment_display
///////////////////////////////////////////////////////////////////////////////
module engine_tb();

    reg clk;

    // Instruction busses
    wire [2:0] op;
    wire [3:0] s1, dest;
    wire [7:0] s2;

    // Control lines
    wire en_alu, stop;
    wire alu_done, alu_stop;

    // Control inputs
    reg alu_rst, exe_rst;

    // Program counter debug
    wire [3:0] pc; 

    // Internal state debug
    wire [1:0] exe_state;
    wire [2:0] alu_state;

    // Memory control
    wire r_rw, m_rw, r_en, m_en;
    
    // Memory address
    wire [1:0] r_address;
    wire [2:0] m_address;
    
    // Memory bus
    wire [255:0] datain, dataout;

    // Instantiate and connect modules
    exe      _exe(op, s1, dest, s2, en_alu, alu_stop, alu_done, exe_rst, clk, exe_state, pc);
    alu      _alu(alu_done, r_rw, m_rw, r_en, m_en, r_address, m_address, datain, dataout, en_alu, alu_stop, alu_rst, clk, op, s1, dest, s2, alu_state);
    register _reg(datain, dataout, r_address, r_en, r_rw, clk);
    memory   _mem(datain, dataout, m_address, m_en, m_rw, clk);

    // Initialize modules
    initial begin
           alu_rst = 1; exe_rst = 1;
        #2 alu_rst = 0; exe_rst = 0;
           clk = 0;
    end

    // Kick off the clock
    initial begin
        forever #10 clk=~clk;
    end

endmodule
