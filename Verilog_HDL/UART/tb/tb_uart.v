`timescale 1ns / 1ps

module tb_uart_controller ();
    parameter TICK_PERIOD = 10 * (100_000_000 / 9600);

    reg clk, reset;
    reg  btn_R;
    wire tx;

    uart_controller dut (
        .clk(clk),
        .reset(reset),
        .btn_R(btn_R),
        .tx(tx)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        btn_R = 0;
        #10;
        reset = 0;

        #TICK_PERIOD;
        btn_R = 1;
        #(10_000);
        btn_R = 0;

        #(TICK_PERIOD*200);
        btn_R = 1;
        #TICK_PERIOD;
        btn_R = 0;
    end
endmodule

module tb_top_data_modified ();
    parameter TICK_PERIOD = 10 * (100_000_000 / 9600);

    reg clk, reset;
    reg tx_start;
    reg [7:0] i_data;
    wire o_baud_tick;
    wire tx;

    baud_tick dut (
        .clk(clk),
        .reset(reset),
        .o_baud_tick(o_baud_tick)
    );

    uart_tx dut_uart (
        .clk(clk),
        .reset(reset),
        .i_baud_tick(o_baud_tick),
        .tx_start(tx_start),
        .i_data(i_data),
        .tx(tx)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        tx_start = 0;
        i_data = 8'b01010101;
        #10;
        reset = 0;

        #TICK_PERIOD;
        #5;
        tx_start = 1;
        #(TICK_PERIOD * 10);
        tx_start = 0;

        #(TICK_PERIOD * 30);
        i_data = 8'b00000000;

        #(TICK_PERIOD * 5);
        $stop;
    end
endmodule

module tb_uart_tx ();
    parameter TICK_PERIOD = 10 * (100_000_000 / 9600);

    reg clk, reset;
    reg tx_start;
    reg [7:0] i_data;
    wire o_baud_tick;
    wire tx;

    baud_tick dut (
        .clk(clk),
        .reset(reset),
        .o_baud_tick(o_baud_tick)
    );

    uart_tx dut_uart (
        .clk(clk),
        .reset(reset),
        .i_baud_tick(o_baud_tick),
        .tx_start(tx_start),
        .i_data(i_data),
        .tx(tx)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        tx_start = 0;
        i_data = 8'b01010101;
        #10;
        reset = 0;

        #TICK_PERIOD;
        #5;
        tx_start = 1;
        #(TICK_PERIOD * 10);
        tx_start = 0;

        #(TICK_PERIOD * 5);
        $stop;
    end
endmodule

module tb_baud_tick_gen ();

    reg clk, reset;
    wire o_baud_tick;

    baud_tick dut (
        .clk(clk),
        .reset(reset),
        .o_baud_tick(o_baud_tick)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #10;
        reset = 0;

        #(200_000);
        $stop;
    end
endmodule
