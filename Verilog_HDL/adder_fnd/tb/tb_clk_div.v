`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/21 15:31:29
// Design Name: 
// Module Name: tb_clk_div
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_clk_div ();

    reg clk, reset;
    wire o_1khz;

    clk_div dut (
        .clk(clk),
        .reset(reset),
        .o_1khz(o_1khz)
    );

    // 5ns 마다 clk이 바뀜
    // 따라서 주기 = 10ns - 하드웨어 clk과 같은 값
    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        // 처음 시작할 때 reset 걸고 시작 - 초기화
        reset = 1;
        #10;
        reset = 0;

        #(500_000 * 4);
        $stop;
    end

endmodule

module tb_clk_div_100mhz ();

    reg clk, reset;
    wire o_50mhz, o_25mhz, o_16mhz, o_8mhz, o_8_1mhz, o_8_2mhz;

    clk_div_2 dut2 (
        .clk(clk),
        .reset(reset),
        .o_50mhz(o_50mhz)
    );

    clk_div_4 dut4 (
        .clk(clk),
        .reset(reset),
        .o_25mhz(o_25mhz)
    );

    clk_div_6 dut6 (
        .clk(clk),
        .reset(reset),
        .o_16mhz(o_16mhz)
    );

    clk_div_12 dut12 (
        .clk(clk),
        .reset(reset),
        .o_8mhz(o_8mhz)
    );

    clk_div_12_2_1 dut12_1 (
        .clk(clk),
        .reset(reset),
        .o_8mhz(o_8_1mhz)
    );

    clk_div_12_1_2 dut12_2 (
        .clk(clk),
        .reset(reset),
        .o_8mhz(o_8_2mhz)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 1;
        reset = 1;
        #10;
        reset = 0;

        #(100 * 10);
        $stop;
    end

endmodule
