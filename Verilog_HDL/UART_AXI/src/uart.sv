`timescale 1ns / 1ps

module tick_gen #(
    // default: 9600 baud tick
    parameter COUNT_NUM = 100_000_000 / 9600
) (
    input  logic clk,
    input  logic rstn,
    input  logic enable,
    output logic o_tick
);
    logic [$clog2(COUNT_NUM)-1:0] counter_reg;

    always_ff @(posedge clk) begin
        if (!rstn) begin
            counter_reg <= 0;
            o_tick <= 0;
        end else begin
            if (enable) begin
                o_tick <= 0;
                counter_reg <= counter_reg + 1;
                if (counter_reg == COUNT_NUM - 1) begin
                    counter_reg <= 0;
                    o_tick <= 1;
                end
            end else begin
                o_tick <= 0;
                counter_reg <= 0;
            end
        end
    end

endmodule

module uart_tx (
    input logic clk,
    input logic rstn,
    input logic start,  // 전송 시작
    input logic [7:0] tx_data,  // 전송할 데이터
    output logic tx_done,  // 전송 완료
    output logic tx  // -> to pc
);
    logic [7:0] data_reg;
    logic [7:0] idx, idx_next;
    logic enable;

    parameter BAUD_COUNT = 100_000_000 / 9600;
    logic baud_tick;
    tick_gen #(BAUD_COUNT) baud_tick_gen (
        .clk(clk),
        .rstn(rstn),
        .enable(enable),
        .o_tick(baud_tick)
    );

    typedef enum logic [1:0] {
        IDLE  = 0,
        START,
        DATA,
        STOP
    } tx_state_e;

    tx_state_e tx_state, tx_state_next;

    always_ff @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            data_reg <= 8'b0;
            tx_state <= IDLE;
            idx <= 0;
        end else begin
            tx_state <= tx_state_next;
            idx <= idx_next;
            if (start) begin
                data_reg <= tx_data;
            end
        end
    end

    assign enable = (tx_state != IDLE) ? 1 : 0;

    always_comb begin
        tx_state_next = tx_state;
        tx_done = 0;
        idx_next = idx;
        case (tx_state)
            IDLE: begin
                tx = 1;
                if (start) begin
                    tx_state_next = START;
                end
            end
            START: begin
                tx = 0;
                if (baud_tick) begin
                    idx_next = 0;
                    tx_state_next = DATA;
                end
            end
            DATA: begin
                tx = data_reg[idx];
                if (baud_tick) begin
                    idx_next = idx + 1;
                    if (idx == 7) begin
                        tx_state_next = STOP;
                    end
                end
            end
            STOP: begin
                tx = 1;
                if (baud_tick) begin
                    tx_state_next = IDLE;
                    tx_done = 1;
                end
            end
        endcase
    end

endmodule

module uart_rx (
    input logic clk,
    input logic rstn,
    output logic rx_done,  // 수신 완료 (데이터 유효)
    output logic [7:0] rx_data,  // 받은 데이터
    input logic rx  // <- from pc
);
    logic [7:0] data_reg;

    parameter BAUD_x16_COUNT = 100_000_000 / (9600 * 16);
    logic baud_x16_tick;

    tick_gen #(BAUD_x16_COUNT) baud_x16_tick_gen (
        .clk(clk),
        .rstn(rstn),
        .enable(1'b1),
        .o_tick(baud_x16_tick)
    );

    typedef enum logic [1:0] {
        IDLE  = 0,
        START,
        DATA,
        STOP
    } rx_state_e;

    rx_state_e rx_state, rx_state_next;
    logic [3:0] x16_counter, x16_counter_next;
    logic [2:0] idx_reg, idx_next;

    always_ff @(posedge clk) begin
        if (!rstn) begin
            rx_data <= 0;
            rx_state <= IDLE;
            x16_counter <= 0;
            idx_reg <= 0;
        end else begin
            rx_data <= data_reg;
            rx_state <= rx_state_next;
            x16_counter <= x16_counter_next;
            idx_reg <= idx_next;
        end
    end

    always_comb begin
        rx_state_next = rx_state;
        x16_counter_next = x16_counter;
        data_reg = rx_data;
        idx_next = idx_reg;
        rx_done = 0;
        case (rx_state)
            IDLE: begin
                if ((rx == 0) && (baud_x16_tick)) begin
                    x16_counter_next = x16_counter + 1;
                    if (x16_counter == 7) begin
                        rx_state_next = START;
                        x16_counter_next = 0;
                    end
                end else begin
                    x16_counter_next = 0;
                end
            end
            START: begin
                if (baud_x16_tick) begin
                    x16_counter_next = x16_counter + 1;
                    if (x16_counter == 15) begin
                        data_reg = 0;
                        idx_next = 0;
                        x16_counter_next = 0;
                        rx_state_next = DATA;
                    end
                end
            end
            DATA: begin
                if (baud_x16_tick) begin
                    x16_counter_next = x16_counter + 1;
                    if (x16_counter == 0) begin
                        data_reg = {rx, rx_data[7:1]};

                        if (idx_reg == 7) begin
                            rx_state_next = STOP;
                        end else begin
                            idx_next = idx_reg + 1;
                        end
                    end
                end
            end
            STOP: begin
                if (baud_x16_tick) begin
                    x16_counter_next = x16_counter + 1;
                    if (x16_counter == 15) begin
                        rx_state_next = IDLE;
                        rx_done = 1;
                        x16_counter_next = 0;
                    end
                end
            end
        endcase
    end

endmodule
