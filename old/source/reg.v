///////////////////////////////////////////////////////////////////////////////
// -=Built using module provided in tracs page=-
// Author: Mark W. Welker
// Modified: James Starks
// 
// This register holds data that will be used to represent a
// 4x4x16bit matrix. This means each register must be 256 bits
// long, and there is 3 registers.
///////////////////////////////////////////////////////////////////////////////
module register(dataout, datain, address, en, rw, clk);
    // Path for the data
    output reg  [255:0] dataout;
    input  wire [255:0] datain;

    // Address points to a register
    input [1:0] address;

    // Register control signals
    input en, rw, clk; 

    // These registers hold matrix data
    reg [255:0] mem_array [1:0];

    // Initialize registers to all zeroes
    initial begin
        mem_array[0] = 255'h0;
        mem_array[1] = 255'h0;
        mem_array[2] = 255'h0;
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
