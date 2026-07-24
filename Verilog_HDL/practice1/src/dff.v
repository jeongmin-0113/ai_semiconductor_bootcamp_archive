`timescale 1ns / 1ps

module dff (
    input clk,
    input din,
    output reg qout
);

    always @(posedge clk) qout <= din;
endmodule

// 1bit din 데이터를 qout에 저장
// 다음 clk 까지 qout 데이터 유지