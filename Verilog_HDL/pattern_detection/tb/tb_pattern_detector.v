`timescale 1ns / 1ps

module tb_pattern_detector ();

    reg clk, reset, i_pattern;
    wire o_detect_mealy, o_detect_moore;

    reg [8:0] target = 9'b001010101;
    integer i;

    pattern_detection_mealy dut_mealy (
        .clk(clk),
        .reset(reset),
        .i_pattern(i_pattern),
        .o_detect(o_detect_mealy)
    );

    pattern_detection_moore dut_moore (
        .clk(clk),
        .reset(reset),
        .i_pattern(i_pattern),
        .o_detect(o_detect_moore)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        i_pattern = 0;
        i=0;
        #10;
        reset = 0;

        #6;
        for (i = 8;i>=0;i=i-1) begin
            i_pattern = target[i];
            #10;
        end

        #10;
        $stop;
    end
endmodule
