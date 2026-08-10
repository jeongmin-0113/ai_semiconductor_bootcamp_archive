`timescale 1ns / 1ps

module tb_ram_ip ();

    reg clk;
    reg [5:0] addr;
    reg [7:0] wdata;
    reg wr;
    wire [7:0] rdata;

    ram_id dut (
        .clk  (clk),
        .addr (addr),
        .wdata(wdata),
        .wr   (wr),
        .rdata(rdata)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        addr = 0;
        wdata = 0;
        wr = 0;
        #10;

        @(negedge clk);
        wr = 1;
        addr = 10;
        wdata = 8'ha;

        @(negedge clk);
        wr = 1;
        addr = 11;
        wdata = 8'hb;

        @(negedge clk);
        wr = 1;
        addr = 31;
        wdata = 8'hc;

        @(negedge clk);
        wr = 1;
        addr = 32;
        wdata = 8'hd;

        @(negedge clk);
        wr = 0;
        addr = 10;

        @(negedge clk);
        wr = 0;
        addr = 11;

        @(negedge clk);
        wr = 0;
        addr = 31;

        @(negedge clk);
        wr = 0;
        addr = 32;

        #100;
        $stop;

    end
endmodule
