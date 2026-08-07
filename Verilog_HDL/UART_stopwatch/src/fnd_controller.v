`timescale 1ns / 1ps

module fnd_controller #(
    parameter MSEC_WIDTH = 7,
    SEC_WIDTH = 6,
    MIN_WIDTH = 6,
    HOUR_WIDTH = 5
) (
    input                   clk,
    input                   reset,
    input  [MSEC_WIDTH-1:0] msec,
    input  [ SEC_WIDTH-1:0] sec,
    input  [ MIN_WIDTH-1:0] min,
    input  [HOUR_WIDTH-1:0] hour,
    input [1:0] state,
    input [1:0] sw,
    input                   display_mode,  // sw[0] -> 0=초/1=시간 선택
    output [           3:0] fnd_com,
    output [           7:0] fnd_data
);
    wire [3:0] w_msec_1, w_msec_10, w_sec_1, w_sec_10, w_min_1, w_min_10, w_hour_1, w_hour_10;
    wire [3:0] bcd;
    wire [3:0] w_msec_sec, w_min_hour;
    wire [2:0] w_digit_sel;
    wire clk_reg;
    wire w_dot_onoff;
    wire [3:0] w_indi_msec_1, w_indi_msec_10, w_indi_sec_1, w_indi_sec_10, w_indi_min_1, w_indi_min_10, w_indi_hour_1, w_indi_hour_10;
    wire [3:0] w_state_out;
    wire indi_digit_1, indi_digit_10;

    state_decoder U_STATE_DC (
        .clk(clk),
        .reset(reset),
        .state(state),
        .state_out(w_state_out)
    );

    indicator U_INDICATOR_MSEC (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .comp(w_dot_onoff),
        .state(w_state_out[0]),
        .digit_1(w_msec_1),
        .digit_10(w_msec_10),
        .indi_digit_1(w_indi_msec_1),
        .indi_digit_10(w_indi_msec_10)
    );

    indicator U_INDICATOR_SEC (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .comp(w_dot_onoff),
        .state(w_state_out[1]),
        .digit_1(w_sec_1),
        .digit_10(w_sec_10),
        .indi_digit_1(w_indi_sec_1),
        .indi_digit_10(w_indi_sec_10)
    );


    indicator U_INDICATOR_MIN (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .comp(w_dot_onoff),
        .state(w_state_out[2]),
        .digit_1(w_min_1),
        .digit_10(w_min_10),
        .indi_digit_1(w_indi_min_1),
        .indi_digit_10(w_indi_min_10)
    );


    indicator U_INDICATOR_HOUR (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .comp(w_dot_onoff),
        .state(w_state_out[3]),
        .digit_1(w_hour_1),
        .digit_10(w_hour_10),
        .indi_digit_1(w_indi_hour_1),
        .indi_digit_10(w_indi_hour_10)
    );


    clk_div U_CLK_DIV (
        .clk(clk),
        .reset(reset),
        .o_1khz(clk_reg)
    );

    counter_8 U_COUNTER_8 (
        .clk(clk_reg),
        .reset(reset),
        .digit_sel(w_digit_sel)
    );

    decoder_2x4 U_DC (
        .sel(w_digit_sel[1:0]),
        .an_com(fnd_com)
    );

    comparator_dot #(MSEC_WIDTH) U_COMP_DOT (
        .msec(msec),
        .dot_onoff(w_dot_onoff)
    );

    // digit splitter
    digit_splitter #(
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_DS_MSEC (
        .ds_in(msec),  // parameter로 변경
        .digit_1(w_msec_1),
        .digit_10(w_msec_10)
    );

    digit_splitter #(
        .BIT_WIDTH(SEC_WIDTH)
    ) U_DS_SEC (
        .ds_in(sec),  // parameter로 변경
        .digit_1(w_sec_1),
        .digit_10(w_sec_10)
    );

    // 8x1 mux - msec & sec display
    mux_8x1 U_MUX_SEC (
        .in0(w_indi_msec_1),
        .in1(w_indi_msec_10),
        .in2(w_indi_sec_1),
        .in3(w_indi_sec_10),
        .in4(4'hf),
        .in5(4'hf),
        .in6({3'b111, w_dot_onoff}),
        .in7(4'hf),
        .sel(w_digit_sel),
        .mux_out(w_msec_sec)
    );

    // digit splitter - min & hour
    digit_splitter #(
        .BIT_WIDTH(MIN_WIDTH)
    ) U_DS_MIN (
        .ds_in(min),  // parameter로 변경
        .digit_1(w_min_1),
        .digit_10(w_min_10)
    );

    digit_splitter #(
        .BIT_WIDTH(HOUR_WIDTH)
    ) U_DS_HOUR (
        .ds_in(hour),  // parameter로 변경
        .digit_1(w_hour_1),
        .digit_10(w_hour_10)
    );

    // mux 8x1 - min & hour display
    mux_8x1 U_MUX_HOUR (
        .in0(w_indi_min_1),  // sel 3'b000
        .in1(w_indi_min_10),  // sel 3'b001
        .in2(w_indi_hour_1),  // sel 3'b010
        .in3(w_indi_hour_10),  // sel 
        .in4(4'hf),
        .in5(4'hf),
        .in6({3'b111, w_dot_onoff}),
        .in7(4'hf),
        .sel(w_digit_sel),  // mux sel
        .mux_out(w_min_hour)
    );

    // 초:밀리초와 시:분 디스플레이 중 display 모드에 의해 선택된 데이터가 bcd로
    mux_2x1 U_MUX_2x1 (
        .in0(w_msec_sec),
        .in1(w_min_hour),
        .sel(display_mode),
        .mux_out(bcd)
    );

    bcd U_BCD (
        .bcd_in (bcd),
        .bcd_out(fnd_data)
    );

endmodule


module state_decoder (
    input clk,
    input reset,
    input [1:0] state,
    output reg [3:0] state_out
);
    always @(state) begin
        case (state)
            2'b00:   state_out = 4'b0000;
            2'b01:   state_out = 4'b1000;
            2'b10:   state_out = 4'b0100;
            2'b11:   state_out = 4'b0010;
            default: state_out = 4'b0000;
        endcase
    end
endmodule


module indicator (
    input clk,
    input reset,
    input [1:0] sw,
    input comp,
    input state,
    input [3:0] digit_1,
    input [3:0] digit_10,
    output reg [3:0] indi_digit_1,
    output reg [3:0] indi_digit_10
);
    always@(*)begin
        if(comp && state) begin
            indi_digit_1 = 4'hf;
            indi_digit_10 = 4'hf;
        end else begin
            indi_digit_1 = digit_1;
            indi_digit_10 = digit_10;
        end
    end
    // assign indi_digit_1  = (sw[1] & !comp & state) ? 4'hf : digit_1;
    // assign indi_digit_10 = (sw[1] & !comp & state) ? 4'hf : digit_10;

endmodule


module clk_div (
    input  clk,
    input  reset,
    output o_1khz
);

    reg [15:0] counter_reg;
    reg clk_reg;

    assign o_1khz = clk_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            clk_reg <= 1'b0;
        end else begin
            // <= non blocking은 일단 예약 걸고 always 끝난 다음 한번에 반영
            counter_reg <= counter_reg + 1;
            // if문에서 읽어오는 건 예약 반영되기 전의 값.
            if (counter_reg == (50000 - 1)) begin
                counter_reg <= 0;
                clk_reg <= ~clk_reg;
            end
        end
    end

endmodule


module comparator_dot #(
    parameter MSEC_WIDTH = 7
) (
    input [MSEC_WIDTH-1:0] msec,
    output dot_onoff
);
    // 0~49ms -> 0 (켜짐) - led는 0이 켜짐
    // 50~99ms -> 1 (꺼짐)
    assign dot_onoff = (msec < 50);
endmodule

module counter_8 (
    input clk,
    input reset,
    output [2:0] digit_sel
);

    reg [2:0] counter_reg;
    // output과 counter_reg 연결
    // output을 reg로 바꾸는 거랑 차이 없음
    assign digit_sel = counter_reg;

    // sequential logic (SL)
    // reset: clock 비동기 reset
    // reset을 넣어야 하는 이유: counter_reg의 초기화를 위함. 초기화하지 않으면 x라 동작이 이상함
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
        end else begin
            // operation
            // reset은 0이고 clk 상승엣지가 온 것 -> 바로 +1
            // 자동으로 0~3 까지만 카운트: 11 + 1 = 00 (c는 날아감)
            counter_reg <= counter_reg + 1;
        end
    end

endmodule

module digit_splitter #(
    parameter BIT_WIDTH = 7
) (
    input  [BIT_WIDTH-1:0] ds_in,    // parameter로 변경
    output [          3:0] digit_1,
    output [          3:0] digit_10
);

    assign digit_1  = ds_in % 10;
    assign digit_10 = (ds_in / 10) % 10;

endmodule

module mux_2x1 (
    input [3:0] in0,
    input [3:0] in1,
    input sel,
    output [3:0] mux_out
);

    assign mux_out = (sel) ? in1 : in0;

endmodule

module mux_8x1 (
    input [3:0] in0,
    input [3:0] in1,
    input [3:0] in2,
    input [3:0] in3,
    input [3:0] in4,
    input [3:0] in5,
    input [3:0] in6,
    input [3:0] in7,
    input [2:0] sel,
    output reg [3:0] mux_out
);

    always @(*) begin
        case (sel)
            3'b000:  mux_out = in0;
            3'b001:  mux_out = in1;
            3'b010:  mux_out = in2;
            3'b011:  mux_out = in3;
            3'b100:  mux_out = in4;
            3'b101:  mux_out = in5;
            3'b110:  mux_out = in6;
            3'b111:  mux_out = in7;
            default: mux_out = 4'b1111;
        endcase
    end

    // assign mux_out = (sel == 2'b00) ? a_digit_1 : 
    //                  (sel == 2'b01) ? a_digit_10 : 
    //                  (sel == 2'b10) ? b_digit_1 : 
    //                  (sel == 2'b11) ? b_digit_10 :
    //                  4'b1111;

endmodule

module decoder_2x4 (
    input [1:0] sel,
    output reg [3:0] an_com
);

    always @(sel) begin
        case (sel)
            2'b00:   an_com = 4'b1110;
            2'b01:   an_com = 4'b1101;
            2'b10:   an_com = 4'b1011;
            2'b11:   an_com = 4'b0111;
            default: an_com = 4'b1111;
        endcase
    end

endmodule


module bcd (
    input [3:0] bcd_in,
    output reg [7:0] bcd_out
);

    // bcd_in 값이 바뀔때마다 (이벤트 발생) begin
    // 내부에 assign 문 사용 불가
    // always 구문의 출력은 항상 reg 타입이어야 함
    always @(bcd_in) begin
        case (bcd_in)
            4'b0000: bcd_out = 8'hC0;  // 0
            4'b0001: bcd_out = 8'hF9;  // 1
            4'b0010: bcd_out = 8'hA4;  // 2
            4'b0011: bcd_out = 8'hB0;  // 3
            4'b0100: bcd_out = 8'h99;  // 4
            4'b0101: bcd_out = 8'h92;  // 5
            4'b0110: bcd_out = 8'h82;  // 6
            4'b0111: bcd_out = 8'hF8;  // 7
            4'b1000: bcd_out = 8'h80;  // 8
            4'b1001: bcd_out = 8'h90;  // 9
            4'b1010: bcd_out = 8'h88;  // a
            4'b1011: bcd_out = 8'h83;  // b
            4'b1100: bcd_out = 8'hC6;  // c
            4'b1101: bcd_out = 8'hA1;  // d
            4'b1110: bcd_out = 8'h7f;  // dp on
            4'b1111: bcd_out = 8'hff;  // dp off
        endcase
    end

endmodule
