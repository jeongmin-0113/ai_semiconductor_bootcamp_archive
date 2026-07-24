`timescale 1ns / 1ps

module tb_top_module_10000 ();

    reg clk, reset;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

    top_module_10000 dut (
        .clk(clk),
        .reset(reset),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        #10;
        reset = 0;

        #(1_000_000 * 10 * 20);
        $stop;
    end

endmodule

module tb_datapath_10000 ();

    reg clk, reset;
    wire [13:0] count;

    datapath_10000 dut (
        .clk  (clk),
        .reset(reset),
        .count(count)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #10;
        reset = 0;

        #(1_000_000 * 10 * 10);
        $stop;
    end
endmodule


module tb_tick_gen ();

    reg clk, reset;
    wire tick;

    tick_generator dut (
        .clk  (clk),
        .reset(reset),
        .tick (tick)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #10;
        reset = 0;

        #(1_000_000 * 10 * 2);
        $stop;
    end

endmodule
