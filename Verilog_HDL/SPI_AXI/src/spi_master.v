`timescale 1ns / 1ps

module spi_master (
    input wire clk,
    input wire rstn,

    // internal signals
    input  wire [7:0] clk_div,
    input  wire        start,
    input  wire [ 7:0] tx_data,
    output wire [ 7:0] rx_data,
    output wire        busy,
    output wire        done,

    // external port
    output wire sclk,
    output wire mosi,
    input  wire miso,
    output wire ss_n
);

    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;
    reg [1:0] state;

    reg sclk_r, busy_r, done_r, mosi_r, ss_r;
    reg [7:0] tx_shift_reg, rx_shift_reg, rx_data_r;
    reg [2:0] bit_cnt;
    reg half_tick, step;
    reg [31:0] half_tick_cnt, clk_div_r;

    assign sclk = sclk_r;
    assign busy = busy_r;
    assign done = done_r;
    assign mosi = mosi_r;
    assign ss_n = ss_r;
    assign rx_data = rx_data_r;

    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            half_tick_cnt <= 0;
            half_tick <= 0;
        end else begin
            half_tick_cnt <= 0;
            if (state != IDLE) begin
                half_tick_cnt <= half_tick_cnt + 1;
                half_tick <= 0;
                if (half_tick_cnt == clk_div_r) begin
                    half_tick_cnt <= 0;
                    half_tick <= 1;
                end
            end
        end
    end

    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            state        <= IDLE;
            sclk_r       <= 0;
            busy_r       <= 0;
            done_r       <= 0;
            mosi_r       <= 1;
            ss_r         <= 1;
            tx_shift_reg <= 0;
            rx_shift_reg <= 0;
            bit_cnt      <= 0;
            clk_div_r    <= 0;
            step         <= 0;
        end else begin
            case (state)
                IDLE: begin
                    sclk_r <= 1'b0;
                    mosi_r <= 1'b1;
                    ss_r   <= 1'b1;
                    busy_r <= 1'b0;
                    done_r <= 1'b0;
                    if (start) begin
                        clk_div_r    <= clk_div;
                        state        <= START;
                        tx_shift_reg <= tx_data;  // tx_data 저장
                        busy_r       <= 1'b1;  // 통신 시작 -> busy
                        ss_r         <= 1'b0;  // 통신 시작 -> slave select
                        bit_cnt      <= 0;  // 0번 bit부터 차례로 전송
                    end
                end
                START: begin
                    // 1bit 송신 후 data로 -> start되자마자 바로 1bit보내야되니까
                    state <= DATA;
                    mosi_r <= tx_shift_reg[7];
                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                end
                DATA: begin

                    // 1bit 보낸 후 다음부터는 half tick마다 수신 / 송신 번갈아 동작한다
                    if (half_tick) begin
                        sclk_r <= ~sclk_r;
                        // sclk의 몇번째 edge냐에 따라 다른 동작 수행
                        if (step == 1'b0) begin
                            // 1번 송신한 후 0번째 edge -> 현재 SPO == 0이므로 다음 edge는 rising
                            // receive
                            step <= 1;
                            rx_shift_reg <= {
                                rx_shift_reg[6:0], miso
                            };  // rx data받으며 shift
                        end else begin
                            // 1번 송신한 후 1번째 edge -> falling (송신) -> send
                            step <= 0;
                            mosi_r <= tx_shift_reg[7]; // 7번째 bit를 보내고
                            tx_shift_reg <= {
                                tx_shift_reg[6:0], 1'b0
                            };  // tx data는 shift
                            bit_cnt <= bit_cnt + 1;
                            if (bit_cnt == 7) begin // start에서 1bit + data에서 7bit 전부 보내면 stop
                                state <= STOP;
                                rx_data_r <= rx_shift_reg;
                            end
                        end
                    end
                end
                STOP: begin
                    state  <= IDLE;
                    ss_r   <= 1'b1;  // 선택 해제
                    sclk_r <= 1'b0;
                    done_r <= 1'b1;
                    busy_r <= 1'b0;
                    mosi_r <= 1'b1;
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
