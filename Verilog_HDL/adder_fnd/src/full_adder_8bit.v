`timescale 1ns / 1ps


module full_adder_8bit(
    input [7:0] a,
    input [7:0] b,
    output [7:0] s,
    output c
    );

    wire c2;

    full_adder_4bit FA1 (
        .a(a[3:0]),
        .b(b[3:0]),
        .cin(1'b0),
        .s(s[3:0]),
        .c(c2)
    );

    full_adder_4bit FA2 (
        .a(a[7:4]),
        .b(b[7:4]),
        .cin(c2),
        .s(s[7:4]),
        .c(c)
    );

endmodule