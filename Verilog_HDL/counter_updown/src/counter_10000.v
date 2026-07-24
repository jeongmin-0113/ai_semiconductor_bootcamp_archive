`timescale 1ns / 1ps


module top_module_10000 (
    input        clk,
    input        reset,
    input        btn_L,     // 0:up / 1:down
    input        btn_R,      // 0: stop / 1:run
    input        btn_UP,    // 0:normal / 1:clear
    output [3:0] fnd_com,
    output [7:0] fnd_data
);

    wire [13:0] w_count;
    wire w_reset;

    wire w_run_stop, w_clear, w_mode;

    assign w_reset = reset | w_clear;

    // btn debounce logic 필요
    // btn - clk 비동기이므로 디바운스가 필요한 것임

    control_unit U_CNTL (
        .clk(clk),
        .reset(reset),
        .i_runstop(btn_L),
        .i_clear(btn_R),
        .i_mode(btn_UP),
        .o_runstop(w_run_stop),
        .o_clear(w_clear),
        .o_mode(w_mode)
    );

    datapath_10000 U_DATA_PATH (
        .clk(clk),
        .reset(w_reset),
        .mode(w_mode),  // 0:up / 1:down
        .run(w_run_stop),  // 0: stop / 1:run
        .count(w_count)
    );

    fnd_controller U_FND_CTRL (
        .clk(clk),
        .reset(w_reset),
        .fnd_in(w_count),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

endmodule

module datapath_10000 (
    input clk,
    input reset,
    input mode,  // 0:up / 1:down
    input run,  // 0: stop / 1:run
    output [13:0] count
);
    wire w_tick;

    counter_10000 U_COUNTER (
        .clk(clk),
        .reset(reset),
        .i_tick(w_tick),
        .mode(mode),  // 0:up / 1:down
        .run(run),  // 0: stop / 1:run
        .count(count)
    );

    tick_generator U_TICK_GEN (
        .clk  (clk),
        .reset(reset),
        .tick (w_tick)
    );

endmodule

module counter_10000 (
    input         clk,
    input         reset,
    input         i_tick,
    input         mode,    // 0:up / 1:down
    input         run,     // 0: stop / 1:run
    output [13:0] count
);
    reg [$clog2(10_000)-1:0] tick_cnt;
    assign count = tick_cnt;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            tick_cnt <= 0;
        end else begin
            if (i_tick && run) begin
                case (mode)
                    0: tick_cnt <= tick_cnt + 1;
                    1: tick_cnt <= tick_cnt - 1;
                endcase
                if (tick_cnt == 10_000 - 1 && !mode) begin
                    tick_cnt <= 0;
                end else if (tick_cnt == 0 && mode) begin
                    tick_cnt <= 9999;
                end
            end
        end
    end

endmodule

module counter_10000_example (
    input         clk,
    input         reset,
    input         i_tick,
    input         mode,    // 0:up / 1:down
    input         run,     // 0: stop / 1:run
    output [13:0] count
);
    reg [$clog2(10_000)-1:0] tick_cnt;
    assign count = tick_cnt;

    always @(posedge clk, posedge reset) begin
        // 지금 if 차원이 너무 많음 
        // if -> mux: mux를 너무 많이 쓰면 delay 발생할 수 있음
        // 특히, 나누기 곱하기 같은거 쓰면 더 그럴 수 있다
        // 어떻게 해결? if문 수를 줄이자!
        if (reset) begin
            tick_cnt <= 0;
        end else begin
            if (run) begin
                if (!mode) begin  // mode=0: up counter mode
                    if (i_tick) begin
                        tick_cnt <= tick_cnt + 1;
                        if (tick_cnt == 10_000 - 1) begin
                            tick_cnt <= 0;
                        end
                    end
                end else begin  // mode=1: down counter mode
                    if (i_tick) begin
                        tick_cnt <= tick_cnt - 1;
                        if (tick_cnt == 0) begin
                            tick_cnt <= 9999;
                        end
                    end
                end
            end
        end
    end

endmodule


module tick_generator (
    input  clk,
    input  reset,
    output tick
);

    reg [$clog2(1_000_000)-1:0] counter_reg;
    reg tick_reg;

    assign tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            tick_reg <= 0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == 1_000_000 - 1) begin
                counter_reg <= 0;
                tick_reg <= 1'b1;
            end else begin
                // 999_999 아닌 경우에는 모두 tick이 0이어야 함
                tick_reg <= 1'b0;
            end
        end
    end

endmodule
