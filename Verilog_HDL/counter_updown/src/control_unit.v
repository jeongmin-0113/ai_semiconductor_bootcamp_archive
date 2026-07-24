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

    // 다른 모듈의 입력이 원래 스위치였으므로
    // 스위치 입력과 같은 결과를 가지는 신호를 output 출력 --> 기존 모듈 수정 없이 사용 가능
    assign {o_clear, o_runstop, o_mode} = (c_state == STOP) ? 3'b000 :
                                          (c_state == RUN) ? 3'b010 :   // run btn을 sw처럼 동작하도록 신호 출력
                                          (c_state == CLEAR) ? 3'b100 :
                                          (c_state == MODE) ? 3'b000 : 3'b000;

    // state reg
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state <= STOP;
        end else begin
            c_state <= n_state;
        end
    end

    // next state CL
    always @(*) begin
        n_state = c_state;
        case (c_state)
            STOP: begin
                if (i_runstop) n_state = RUN;
                else if (i_clear) n_state = CLEAR;
                else if (i_mode) n_state = MODE;
                else n_state = c_state;
            end
            RUN: begin
                if (i_runstop) n_state = STOP;
                else n_state = c_state;
            end
            CLEAR: n_state = STOP;
            MODE: n_state = STOP;
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
