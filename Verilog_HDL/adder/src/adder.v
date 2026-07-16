`timescale 1ns / 1ps

module adder ();


endmodule

module full_adder_4bit (
    input [3:0] a,
    input [3:0] b,
    input cin,
    output [3:0] s,
    output c
);

    wire c1, c2, c3;

    full_adder FA1 (
        .a(a[0]),
        .b(b[0]),
        .c_in(cin),
        .s(s[0]),
        .c(c1)
    );

    full_adder FA2 (
        .a(a[1]),
        .b(b[1]),
        .c_in(c1),
        .s(s[1]),
        .c(c2)
    );

    full_adder FA3 (
        .a(a[2]),
        .b(b[2]),
        .c_in(c2),
        .s(s[2]),
        .c(c3)
    );

    full_adder FA4 (
        .a(a[3]),
        .b(b[3]),
        .c_in(c3),
        .s(s[3]),
        .c(c)
    );

endmodule

module full_adder (
    input  a,
    input  b,
    input  c_in,
    output s,
    output c
);

    wire s1, c1, s2, c2;

    half_adder HA1 (
        .a(a),
        .b(b),
        .s(s1),
        .c(c1)
    );

    half_adder HA2 (
        .a(s1),
        .b(c_in),
        .s(s2),
        .c(c2)
    );

    assign s = s2;
    assign c = c1 | c2;

endmodule

module half_adder (
    input  a,
    input  b,
    output s,
    output c
);

    assign s = a ^ b;
    assign c = a & b;

endmodule
