`timescale 1ns / 1ps

module sr04_controller (
    input        clk,
    input        reset,
    input        i_start,
    input        echo,
    output       trigger,
    output       o_done,
    output       o_ready,
    output       o_error,
    output [8:0] distance
);

    parameter READY = 3'b000;
    parameter START = 3'b001;
    parameter WAIT = 3'b010;
    parameter RECEIVE = 3'b011;
    parameter DONE = 3'b100;
    parameter ERROR = 3'b101;

    wire w_tick_1us;

    reg [2:0] c_state, n_state;
    reg done_reg, ready_reg, error_reg;
    reg done_next, ready_next, error_next;

    assign {o_done, o_ready, o_error} = {done_reg, ready_reg, error_reg};

    reg trigger_reg, trigger_next;

    assign trigger = trigger_reg;

    reg [$clog2(10_000)-1:0] tick_count_reg, tick_count_next;
    // reg [$clog2(60_000)-1:0] duration_count_reg, duration_count_next;
    reg [$clog2(40_000)-1:0] high_count_reg, high_count_next;

    reg [8:0] distance_reg, distance_next;

    assign distance = distance_reg;

    tick_gen_1Mhz U_TICK_GEN_1MHZ (
        .clk(clk),
        .reset(reset),
        .i_runstop(i_start),
        .i_clear(o_done | o_error),
        .o_tick(w_tick_1us)
    );

    // state reg
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state        <= READY;
            done_reg       <= 0;
            ready_reg      <= 1;
            error_reg      <= 0;
            tick_count_reg <= 0;
            // duration_count_reg <= 0;
            high_count_reg <= 0;
            distance_reg   <= 0;
            trigger_reg    <= 0;
        end else begin
            c_state        <= n_state;
            done_reg       <= done_next;
            ready_reg      <= ready_next;
            error_reg      <= error_next;
            tick_count_reg <= tick_count_next;
            // duration_count_reg <= duration_count_next;
            high_count_reg <= high_count_next;
            distance_reg   <= distance_next;
            trigger_reg    <= trigger_next;
        end
    end

    // next state CL
    always @(*) begin
        n_state         = c_state;
        done_next       = done_reg;
        ready_next      = ready_reg;
        error_next      = error_reg;
        tick_count_next = tick_count_reg;
        // duration_count_next = duration_count_reg;
        high_count_next = high_count_reg;
        distance_next   = distance_reg;
        trigger_next    = trigger_reg;
        case (c_state)
            READY: begin
                ready_next = 1;
                error_next = 0;
                done_next  = 0;
                if (i_start) begin
                    n_state = START;
                    tick_count_next = 0;
                    // duration_count_next = 0;
                    ready_next = 0;
                    trigger_next = 1;
                    distance_next = 0;
                    high_count_next = 0;
                end
            end
            START: begin
                ready_next   = 0;
                trigger_next = 1;
                if (w_tick_1us) begin
                    if (tick_count_reg >= 11) begin
                        n_state = WAIT;
                        tick_count_next = 0;
                        // duration_count_next = 0;
                        trigger_next = 0;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            WAIT: begin
                if (w_tick_1us) begin
                    // duration_count_next = duration_count_reg + 1;
                    // if (duration_count_reg >= 59_999) begin
                    //     n_state = ERROR;
                    // end else 
                    if (echo == 1) begin
                        n_state = RECEIVE;
                    end
                end
            end
            RECEIVE: begin
                if (w_tick_1us) begin
                    // duration_count_next = duration_count_reg + 1;
                    // if (duration_count_reg >= 59_999) begin
                    //     n_state = ERROR;
                    // end else 
                    // todo: 18ms 이상 -> echo 측정 오류
                    if (echo == 1) begin
                        high_count_next = high_count_reg + 1;
                    end else begin
                        if (high_count_reg >= 23_199) begin
                            n_state = ERROR;
                            distance_next = 0;
                            high_count_next = 0;
                            tick_count_next = 0;
                            done_next = 1;
                        end else begin
                            n_state = DONE;
                            tick_count_next = 0;
                            distance_next = high_count_reg / 58;
                            high_count_next = 0;
                            done_next = 1;
                        end
                    end
                end
            end
            DONE: begin
                done_next = 0;
                if (w_tick_1us) begin
                    if (tick_count_reg >= 9_999) begin
                        n_state = READY;
                        tick_count_next = 0;
                        // duration_count_next = 0;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            ERROR: begin
                done_next = 0;
                error_next = 1;
                // duration_count_next = 0;
                distance_next = 0;
                if (w_tick_1us) begin
                    if (tick_count_reg >= 9_999) begin
                        n_state = READY;
                        tick_count_next = 0;
                        // duration_count_next = 0;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
        endcase
    end


endmodule

module sr04_controller_example (
    input            clk,
    input            reset,
    input            i_start,
    input            echo,
    output reg       trigger,
    output           o_done,
    // output       o_ready,
    // output       o_error,
    output     [8:0] distance
);

    wire w_tick_us;
    reg w_run_stop, w_clear;

    // fsm control unit state
    localparam [2:0] IDLE = 0, START = 1, WAIT = 2, COUNT = 3, DISTANCE = 4;
    reg [2:0] c_state, n_state;

    // 1cm = 58us, 최대 echo 길이 400
    reg [$clog2(58*400)-1:0] tick_counter_reg, tick_counter_next;

    tick_us_example TICK_US (
        .clk(clk),
        .reset(reset),
        .i_runstop(w_run_stop),
        .i_clear(w_clear),
        .o_tick(w_tick_us)
    );


    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state <= IDLE;
            tick_counter_reg <= 0;
        end else begin
            c_state <= n_state;
            tick_counter_reg <= tick_counter_next;
        end
    end

    // next, output CL
    always @(*) begin
        n_state = c_state;
        tick_counter_next = tick_counter_reg;
        w_run_stop = 1'b0;
        w_clear = 1'b0;
        trigger = 1'b0;
        case (c_state)
            IDLE: begin
                w_run_stop = 1'b0;
                w_clear = 1'b1;
                if (i_start) begin
                    n_state = START;
                    tick_counter_next = 0;
                end
            end
            START: begin
                w_run_stop = 1'b1;
                w_clear = 1'b0;
                trigger = 1'b1;
                if (w_tick_us) begin
                    tick_counter_next = tick_counter_reg + 1;
                end
                if (tick_counter_reg >= 11) begin
                    n_state = WAIT;
                end
            end
            WAIT: begin
                // test
                n_state = IDLE;
                w_run_stop = 1'b1;
                trigger = 0;
            end

        endcase
    end



endmodule

module tick_gen_1Mhz (
    input clk,
    input reset,
    input i_runstop,
    input i_clear,
    output reg o_tick
);

    parameter F_COUNT = 100;
    reg [$clog2(F_COUNT)-1:0] counter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            o_tick <= 0;
        end else begin
            if (counter_reg >= F_COUNT - 1) begin
                counter_reg <= 0;
                o_tick <= 1;
            end else begin
                counter_reg <= counter_reg + 1;
                o_tick <= 0;
            end
        end
    end
endmodule


module tick_us_example (
    input clk,
    input reset,
    input run_stop,
    input clear,
    output reg o_tick_us
);

    parameter F_COUNT = 100;

    reg [$clog2(F_COUNT)-1:0] counter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg >= F_COUNT - 1) begin
                counter_reg <= 0;
                o_tick_us   <= 1;
            end else begin
                o_tick_us <= 0;
            end
        end
    end


endmodule
