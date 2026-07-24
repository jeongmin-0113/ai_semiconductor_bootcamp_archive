`timescale 1ns / 1ps

module tb_practice1 ();

    reg clk, a, b;
    initial begin
        a   = 0;
        b   = 1;
        clk = 0;
    end

    always #5 clk = ~clk;

    // blocking
    // a 변경이 완료된 다음 b가 a의 값을 참조
    // 따라서 a = b = 1이 된다
    always @(posedge clk) begin
        a = b;
        b = a;
        $display("a = %d\nb = %d", a, b);
    end

    // // non blocking
    // always @(posedge clk) begin
    //     a <= b;
    //     b <= a;
    // end

endmodule

module tb_delay ();

    reg blk_a, blk_b, blk_c, nblk_a, nblk_b, nblk_c;
    initial begin
        blk_a = #15 1'b1;
        blk_b = #5 1'b0;
        blk_c = #10 1'b1;
        #50 $finish;
    end

    initial begin
        nblk_a <= #15 1'b1;
        nblk_b <= #5 1'b0;
        nblk_c <= #10 1'b1;
        #50 $finish;
    end
endmodule

