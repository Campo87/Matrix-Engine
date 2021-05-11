// -----------------------------------------------------------------------------
// FILE NAME : mem.v
// AUTHOR : JAMES STARKS
// -----------------------------------------------------------------------------
// DESCRIPTION
// Asynchronous single-port memory. This memory module contains 256 256-bit
// registers.
// 
// en_i:  "0" Set data_o to high impedence 
//        "1" Check rw_i for read write logic
// 
// rw_i:  "0" Write data_i into memory, set data_o to high impedence
//        "1" Read memory to data_o
// -----------------------------------------------------------------------------
module mem(
    input   [255:0] data_i,
    input   [7:0]   address_i,
    input           en_i,
    input           rw_i,
    input           clk_i,
    output  [255:0] data_o
);
    reg [255:0] data_o;
    
    // Main storage
    reg [255:0] memory [7:0];


    always @ (posedge clk_i) begin
        if(en_i == 1'b1) begin
            if(rw_i == 1'b1) begin : read
                data_o <= memory[address_i];
            end
            else begin : write
                memory[address_i] <= data_i;
            end
        end
        else begin
            data_o <= 256'bz;
        end
    end 

endmodule
