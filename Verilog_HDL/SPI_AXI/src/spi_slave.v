`timescale 1ns / 1ps


module spi_slave (
    input wire clk,
    input wire rstn,

    // internal signals
    input  wire [7:0] tx_data,
    output wire [7:0] rx_data,
    output wire       busy,
    output wire       done,

    // external port
    input  wire sclk,
    input  wire mosi,
    output wire miso,
    input  wire ss_n
);

    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;
    reg [1:0] state;

    reg prev_sclk;
    reg busy_r, done_r, miso_r;
    reg [7:0] tx_shift_reg, rx_shift_reg, rx_data_r;
    reg [2:0] bit_cnt;

    assign busy = busy_r;
    assign done = done_r;
    assign miso = miso_r;
    assign rx_data = rx_data_r;

    reg sclk_sync0, sclk_sync;
    reg mosi_sync0, mosi_sync;
    reg ss_n_sync0, ss_n_sync;

    always @(posedge clk) begin
        if (!rstn) begin
            sclk_sync0 <= 0;
            sclk_sync <= 0;
            mosi_sync0 <= 1;
            mosi_sync <= 1;
            ss_n_sync0 <= 1;
            ss_n_sync <= 1;
        end else begin
            sclk_sync <= sclk_sync0;
            sclk_sync0 <= sclk;
            mosi_sync <= mosi_sync0;
            mosi_sync0 <= mosi;
            ss_n_sync <= ss_n_sync0;
            ss_n_sync0 <= ss_n;
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            state <= IDLE;
            prev_sclk <= 0;
            busy_r <= 0;
            done_r <= 0;
            miso_r <= 1;
            rx_data_r <= 0;
        end else begin
            prev_sclk <= sclk_sync;
            if (ss_n_sync) state <= IDLE;
            case (state)
                IDLE: begin
                    busy_r <= 0;
                    done_r <= 0;
                    miso_r <= 1;
                    // slave 선택되었다면 -> start (데이터 받을 준비)
                    if (!ss_n_sync) begin
                        state <= START;
                        tx_shift_reg <= tx_data;
                        bit_cnt <= 0;
                        busy_r <= 1;
                    end
                end
                START: begin
                    // 1bit 송신 후 data로 -> start되자마자 바로 1bit 보내는용
                    state <= DATA;
                    miso_r <= tx_shift_reg[7];
                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                end
                DATA: begin
                    // SPO == 0
                    // rising edge (0 -> 1) receive
                    // falling edge (1 -> 0) send
                    case ({
                        prev_sclk, sclk_sync
                    })
                        2'b01: begin  // rising edge -> receive
                            rx_shift_reg <= {rx_shift_reg[6:0], mosi_sync};
                        end
                        2'b10: begin  // falling edge -> send
                            miso_r <= tx_shift_reg[7];
                            tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                            bit_cnt <= bit_cnt + 1;
                            if (bit_cnt == 7) begin
                                state <= STOP;
                                rx_data_r <= rx_shift_reg;
                            end
                        end
                        default: begin
                        end
                    endcase
                end
                STOP: begin
                    state <= IDLE;
                    done_r <= 1'b1;
                    busy_r <= 1'b0;
                    miso_r <= 1'b1;
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
