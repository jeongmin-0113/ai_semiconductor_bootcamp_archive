`timescale 1ns / 1ps

module tb_top_module_10000 ();

    reg clk, reset;
    reg btn_L, btn_R, btn_UP;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

    parameter TEST_DELAY = 10_000_000;

    top_module_10000 dut (
        .clk     (clk),
        .reset   (reset),
        .btn_L    (btn_L), 
        .btn_R     (btn_R), 
        .btn_UP   (btn_UP), 
        .fnd_com (fnd_com),
        .fnd_data(fnd_data)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        {btn_R, btn_L, btn_UP} = 3'b000;
        #10;
        reset = 0;

        // 1    stop
        {btn_R, btn_L, btn_UP} = 3'b000;
        #(TEST_DELAY);

        // 2    RUN_BTN_PUSH
        #6;
        {btn_R, btn_L, btn_UP} = 3'b010;
        #10;
        // 2    RUN
        {btn_R, btn_L, btn_UP} = 3'b000;
        #(TEST_DELAY);

        #1000;
        $stop;
    end

endmodule


module tb_counter_10000 ();

    reg clk, reset, i_tick;
    reg mode, run, clear;
    wire count;

    counter_10000 dut (
        .clk(clk),
        .reset(reset | clear),
        .i_tick(i_tick),
        .mode(mode),    // 0:up / 1:down
        .run(run),     // 0: stop / 1:run
        .count(count)
    );

    always #5 clk = ~clk;
    always #10 i_tick = ~i_tick;

    initial begin
        clk   = 0;
        reset = 1;
        i_tick = 0;
        mode  = 0;
        run   = 0;
        clear = 0;
        #10;
        reset = 0;

        mode  = 1;
        run   = 1;
        clear = 0;
        #40;

        mode  = 1;
        run   = 0;
        clear = 0;
        #20;

        mode  = 0;
        run   = 1;
        clear = 0;
        #100;

        mode  = 0;
        run   = 1;
        clear = 1;
        #20;
    end
endmodule
