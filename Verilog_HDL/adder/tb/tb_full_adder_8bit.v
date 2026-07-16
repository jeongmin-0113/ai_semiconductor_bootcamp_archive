`timescale 1ns / 1ps

module tb_full_adder_8bit ();

    reg [7:0] a, b;
    wire [7:0] s;
    wire c;

    integer i, j, k;

    full_adder_8bit FA (
        .a  (a),
        .b  (b),
        .s  (s),
        .c  (c)
    );

    initial begin
        a   = 8'b0;
        b   = 8'b0;

        for (i = 0; i < 256; i = i + 1) begin
            for (j = 0; j < 256; j = j + 1) begin
                a   = i;
                b   = j;
                #10;
            end
        end

        $stop;

    end

endmodule
