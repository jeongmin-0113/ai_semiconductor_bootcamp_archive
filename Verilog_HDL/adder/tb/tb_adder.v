`timescale 1ns / 1ps


module tb_adder ();

endmodule

module tb_full_adder_4bit ();

    reg [3:0] a, b;
    reg cin;
    wire [3:0] s;
    wire c;

    // in simulation, can use integer
    // 32bit integer (same as c)
    integer i, j, k;

    full_adder_4bit dut (
        .a(a),
        .b(b),
        .cin(cin),
        .s(s),
        .c(c)
    );

    initial begin
        a = 4'b0000;
        b = 4'b0000;
        cin = 1'b0;

        for (k = 0; k < 2; k = k + 1) begin
            for (i = 0; i < 16; i = i + 1) begin
                for (j = 0; j < 16; j = j + 1) begin
                    a = i;
                    b = j;
                    cin = k;
                    #10;
                end
            end
        end

        $stop;
    end

endmodule

module tb_full_adder ();

    reg a, b, cin;
    wire s, c;

    // dut: design under test
    full_adder dut (
        .a   (a),
        .b   (b),
        .c_in(cin),
        .s   (s),
        .c   (c)
    );

    initial begin
        a   = 0;
        b   = 0;
        cin = 0;

        #10;
        a   = 0;
        b   = 1;
        cin = 0;

        #10;
        a   = 1;
        b   = 0;
        cin = 0;

        #10;
        a   = 1;
        b   = 1;
        cin = 0;

        #10;
        a   = 0;
        b   = 0;
        cin = 1;

        #10;
        a   = 0;
        b   = 1;
        cin = 1;

        #10;
        a   = 1;
        b   = 0;
        cin = 1;

        #10;
        a   = 1;
        b   = 1;
        cin = 1;

        #10;
        $stop;  // pause simulation
        $finish;  // end simulation
    end
endmodule
