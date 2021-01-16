///////////////////////////////////////////////////////////////////////////////
// Built off module provided in tracs page
// Author: Mark W. Welker
// Modified: James Starks
// 
// This memory module holds data that will be used to represent
// a 4x4x16bit matrix. This means each register must be 256 bits
// long, and there is 8 registers that can be used for storage.
///////////////////////////////////////////////////////////////////////////////
module memory(dataout, datain, address, en, rw, clk);
    // Path for the data
    output reg  [255:0] dataout;
    input  wire [255:0] datain;

    // Address points to a memory location
    input [2:0] address;
    input en, rw, clk; 

    // Memory control signals
    reg [255:0] mem_array [7:0];

    // Initialize two memory locations with this matrix data
    initial begin
        mem_array[0] = 255'h0004000C0004002200070006000B0009000900020008000D0002000F00100003;
        mem_array[1] = 255'h0017002D001F001600070006000400010012000C000D000C000D000500070013;
    end

    // This memory is clocked
    always@(posedge clk) begin
        if(en) begin
            if(rw) begin
                dataout <= mem_array[address];
            end else begin
                mem_array[address] <= datain;
            end
        end else begin
            dataout <= 256'bz;
        end
    end
endmodule
