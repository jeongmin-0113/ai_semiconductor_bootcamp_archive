`timescale 1ns / 1ps

module tb_debouncer ();

    reg clk, reset, i_btn;
    wire o_btn;

    btn_debouncer dut (
        .clk  (clk),
        .reset(reset),
        .i_btn(i_btn),
        .o_btn(o_btn)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        i_btn = 0;
        #10;
        reset = 0;

        // 1    정상 동작 (10us 입력)
        #6;
        i_btn = 1;
        #(10_000);
        i_btn = 0;
        #(10_000_000);

        // 2    매우 짧은 입력 (5ns)
        #(6+480);
        i_btn = 1;
        #5;
        i_btn = 0;
        #(10_000_000);

        // 3    매우 긴 입력 (20ms)
        #6;
        i_btn = 1;
        #(2_000_000);
        i_btn = 0;
        #(10_000_000);

        $stop;
    end

endmodule
