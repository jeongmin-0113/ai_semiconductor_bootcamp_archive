`timescale 1ns / 1ps

module uart #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115_200
) (
    input clk,
    input rstn,

    // tx internal signal
    input  [7:0] tx_data,
    input        tx_start,
    output       tx_busy,
    output       tx_done,

    // tx external port
    output tx,

    // rx internal signal
    output [7:0] rx_data,
    output rx_done,

    // rx external port
    input rx
);
    uart_tx_review #(CLK_FREQ, BAUD_RATE) u_tx (
        .clk (clk),
        .rstn(rstn),

        // internal signal
        .tx_data (tx_data),
        .tx_start(tx_start),
        .tx_busy (tx_busy),
        .tx_done (tx_done),

        // external port
        .tx(tx)
    );

    uart_rx_review#(CLK_FREQ, BAUD_RATE) u_rx (
        .clk(clk),
        .rstn(rstn),

        // internal signal
        .rx_data(rx_data),
        .rx_done(rx_done),

        // external port
        .rx(rx)
    );

endmodule

module uart_tx_review #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115_200
) (
    input clk,
    input rstn,

    // internal signal
    input  [7:0] tx_data,
    input        tx_start,
    output       tx_busy,
    output       tx_done,

    // external port
    output tx
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam S_IDLE = 2'd0, S_START = 2'd1, S_DATA = 2'd2, S_STOP = 2'd3;
    // localparam S_D0 = 4'd2, S_D1 = 4'd3, S_D2 = 4'd4, S_D3 = 4'd5,
    //            S_D4 = 4'd6, S_D5 = 4'd7, S_D6 = 4'd8, S_D7 = 4'd9;

    reg tx_r, tx_busy_r, tx_done_r;
    reg [1:0] state;
    reg [$clog2(CLKS_PER_BIT)-1:0] clk_cnt;
    reg [2:0] bit_idx;
    reg [7:0] tx_data_r;

    assign tx = tx_r;
    assign tx_busy = tx_busy_r;
    assign tx_done = tx_done_r;

    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            state <= S_IDLE;
            clk_cnt <= 0;
            bit_idx <= 0;
            tx_data_r <= 0;
            tx_busy_r <= 0;
            tx_done_r <= 0;
            tx_r <= 1;
        end else begin
            case (state)
                S_IDLE: begin
                    tx_r <= 1'b1;
                    tx_busy_r <= 1'b0;
                    tx_done_r <= 1'b0;
                    tx_data_r <= 0;
                    if (tx_start) begin
                        state <= S_START;
                        tx_data_r <= tx_data;
                        tx_busy_r <= 1'b1;
                        clk_cnt <= 0;
                    end
                end
                S_START: begin
                    tx_r <= 1'b0;
                    clk_cnt <= clk_cnt + 1;
                    if (clk_cnt == CLKS_PER_BIT) begin
                        state   <= S_DATA;
                        bit_idx <= 0;
                        clk_cnt <= 0;
                    end
                end
                S_DATA: begin
                    tx_r <= tx_data_r[bit_idx];
                    clk_cnt <= clk_cnt + 1;
                    if (clk_cnt == CLKS_PER_BIT) begin
                        clk_cnt <= 0;

                        if (bit_idx == 7) begin
                            state <= S_STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end
                end
                S_STOP: begin
                    tx_r <= 1'b1;
                    clk_cnt <= clk_cnt + 1;
                    if (clk_cnt == CLKS_PER_BIT) begin
                        state <= S_IDLE;
                        clk_cnt <= 0;
                        tx_done_r <= 1;
                    end
                end
                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end

endmodule


module uart_rx_review #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115_200
) (
    input clk,
    input rstn,

    // internal signal
    output [7:0] rx_data,
    output rx_done,

    // external port
    input rx
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam HALF_BIT = CLKS_PER_BIT / 2;
    localparam S_IDLE = 2'd0, S_START = 2'd1, S_DATA = 2'd2, S_STOP = 2'd3;

    reg [1:0] state;
    reg [$clog2(CLKS_PER_BIT)-1:0] clk_cnt;
    reg [2:0] bit_idx;
    reg [7:0] rx_data_r;
    reg rx_done_r;
    reg rx_sync0, rx_sync;

    assign rx_data = rx_data_r;
    assign rx_done = rx_done_r;

    // syncronizer
    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            rx_sync0 <= 1;
            rx_sync  <= 1;
        end else begin
            rx_sync0 <= rx;
            rx_sync  <= rx_sync0;
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            state <= S_IDLE;
            bit_idx <= 0;
            rx_done_r <= 0;
            rx_data_r <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    rx_done_r <= 0;
                    if (!rx_sync) begin
                        state   <= S_START;
                        clk_cnt <= 0;
                    end
                end
                S_START: begin
                    clk_cnt <= clk_cnt + 1;
                    if (clk_cnt == HALF_BIT - 1) begin
                        state   <= S_DATA;
                        clk_cnt <= 0;
                        bit_idx <= 0;
                    end
                end
                S_DATA: begin
                    clk_cnt <= clk_cnt + 1;
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        rx_data_r[bit_idx] <= rx_sync;

                        if (bit_idx == 7) begin
                            state <= S_STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end
                end
                S_STOP: begin
                    clk_cnt <= clk_cnt + 1;
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        bit_idx <= 0;
                        rx_done_r <= 1'b1;
                        state <= S_IDLE;
                    end
                end
                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end

endmodule

