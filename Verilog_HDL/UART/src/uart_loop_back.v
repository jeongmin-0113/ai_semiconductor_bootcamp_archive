`timescale 1ns / 1ps
module uart_loop_back(
    input clk,
    input reset,
    input rx,
    output tx
    );

    wire w_baud_tick_x16;
    wire [7:0] w_rx_data;
    wire w_rx_done;

    baud_tick_x16 U_BAUD_TICK_x16 (
        .clk(clk),
        .reset(reset),
        .o_baud_tick(w_baud_tick_x16)
    );

    uart_tx U_UART_TX (
        .clk(clk),
        .reset(reset),
        .i_baud_tick(w_baud_tick_x16),
        .tx_start(w_rx_done),
        .tx_data(w_rx_data),
        .tx(tx),
        .tx_busy(),
        .tx_done()
    );

    uart_rx U_UART_RX (
        .clk(clk),
        .reset(reset),
        .i_baud_tick(w_baud_tick_x16),
        .rx(rx),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)
    );
endmodule
