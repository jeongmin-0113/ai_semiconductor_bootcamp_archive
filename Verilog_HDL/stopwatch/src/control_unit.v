`timescale 1ns / 1ps

module control_unit (
    input  clk,
    input  reset,
    input  i_runstop,
    input  i_clear,
    input  i_mode,
    output o_runstop,
    output o_clear,
    output o_mode
);

    parameter STOP = 2'b00;
    parameter RUN = 2'b01;
    parameter CLEAR = 2'b10;
    parameter MODE = 2'b11;

    reg [1:0] c_state, n_state;
    reg run_stop_reg, run_stop_next, clear_reg, clear_next, mode_reg, mode_next;

    // 다른 모듈의 입력이 원래 스위치였으므로
    // 스위치 입력과 같은 결과를 가지는 신호를 output 출력 --> 기존 모듈 수정 없이 사용 가능

    // todo: 여기 순차출력으로 변경 - always로 바꾸는게 제일 쉬움
    // assign {o_clear, o_runstop, o_mode} = (c_state == STOP) ? 3'b000 :
    //                                       (c_state == RUN) ? 3'b010 :   // run btn을 sw처럼 동작하도록 신호 출력
    //                                       (c_state == CLEAR) ? 3'b100 :
    //                                       (c_state == MODE) ? 3'b000 : 3'b000;

    assign {o_clear, o_runstop, o_mode} = {clear_reg, run_stop_reg, mode_reg};

    // 순차출력 또 다른 방법
    // 출력도 피드백 구조로 만들기 -> state 동작에 출력 끼워넣기

    // state reg
    // state + output SL
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state <= STOP;
            // 출력 초기화
            run_stop_reg <= 1'b0;
            clear_reg <= 1'b0;
            mode_reg <= 1'b0;
        end else begin
            c_state <= n_state;
            // 출력 피드백 구조
            run_stop_reg <= run_stop_next;
            clear_reg <= clear_next;
            mode_reg <= mode_next;
        end
    end

    // next state CL
    // next state + output CL
    always @(*) begin
        // state init
        n_state = c_state;
        // output init
        run_stop_next = run_stop_reg;
        clear_next = clear_reg;
        mode_next = mode_reg;

        case (c_state)
            STOP: begin
                // next output
                run_stop_next = 1'b0;
                clear_next = 1'b0;
                // next state
                if (i_runstop) n_state = RUN;
                // mealy면 이렇게
                // if (i_runstop) begin 
                //     n_state = RUN;
                //     run_stop_next = 1'b1;
                // end
                else if (i_clear) n_state = CLEAR;
                else if (i_mode) n_state = MODE;
                else n_state = c_state;
            end
            RUN: begin
                // next output
                run_stop_next = 1'b1;
                mode_next = mode_reg;
                // next state
                if (i_runstop) n_state = STOP;
                else n_state = c_state;
            end
            CLEAR: begin
                // next output
                clear_next = 1'b1;
                // next state
                n_state = STOP;
            end
            MODE: begin
                // next output
                mode_next = ~mode_reg;
                // next state
                n_state = STOP;
            end
            default: n_state = c_state;
        endcase
    end

    // output CL
    // mode 값이 계속 0인 오류 있음
    // always @(*) begin
    //     o_runstop = 0;
    //     o_clear = 0;
    //     o_mode = 0;
    //     case (c_state)
    //         STOP: begin
    //             o_runstop = 0;
    //             o_clear   = 0;
    //         end
    //         RUN: begin
    //             o_runstop = 1;
    //         end
    //         CLEAR: begin
    //             o_clear = 1;
    //         end
    //         MODE: begin
    //             o_mode = ~o_mode;
    //         end
    //     endcase
    // end
endmodule
