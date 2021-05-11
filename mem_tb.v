module mem_tb();

    reg  [7:0]   addr;
    reg  [255:0] datain;
    reg          en, rw, clk;
    wire [255:0] dataout;


    mem dut(
        .data_i(datain),
        .address_i(addr),
        .en_i(en),
        .rw_i(rw),
        .clk_i(clk),
        .data_o(dataout)
    );

    initial begin
        datain = 256'b0;
        addr = 8'b0;
        en = 1'b0; rw = 1'b0;
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    
    initial begin
        $monitor("en rw clk\n%b  %b  %b   time: %d\nAddress: %d\nDatain: %d\nDataout: %d\n\n", en, rw, clk, $time, addr, datain, dataout);
        #10
        en = 1'b1; rw = 1'b0;
        addr = 8'b000_1000; datain = 256'd1337;
        #10
        rw = 1'b1;


        #20
        $finish;
    end



endmodule
