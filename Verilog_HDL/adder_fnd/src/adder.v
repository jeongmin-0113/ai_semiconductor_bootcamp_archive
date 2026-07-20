`timescale 1ns / 1ps

module adder_fnd (
    input [7:0] a,
    input [7:0] b,
    input btn_L,
    input btn_R,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output c
);

    wire [7:0] s;

    fnd_controller U_FND_CNTL (
        .fnd_in(s),
        .digit_sel({btn_L, btn_R}),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    full_adder_8bit FA_8bit (
        .a(a),
        .b(b),
        .s(s),
        .c(c)
    );

endmodule


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

    //assign s = a ^ b;
    xor (s, a, b);  // (output, input0, input1, ...)
    //assign c = a & b;
    and (c, a, b);  // (output, input0, input1, ...)
    // 게이트 프리미티브 인스턴스를 쓰든 연산자를 그냥 쓰든 성능 차이 없음

endmodule
