`timescale 1ns / 1ps

module tb_loop_back ();

    parameter TICK_PERIOD = 10 * (100_000_000 / 9600);

    reg clk, reset;
    reg rx;
    wire tx;
    reg [7:0] send_data;
    reg [7:0] receive_data;
    reg [8:0] pass_cnt, fail_cnt;

    integer i, j, k;

    // tx를 모사해 rx에 tick 마다 데이터를 보내는 sw
    task SENDER_FOR_UART_RX(input [7:0] send_data);
        begin
            // start
            rx = 0;
            #TICK_PERIOD;
            // data
            for (i = 0; i < 8; i = i + 1) begin
                rx = send_data[i];
                #TICK_PERIOD;
            end

            // stop
            rx = 1;
            #TICK_PERIOD;
        end
    endtask

    // rx를 모사해 데이터 받아 모으는 sw
    task RECEIVER(output [7:0] data);
        begin
            wait (~tx);  // tx가 0일때까지 기다림
            #(TICK_PERIOD / 2);
            if (tx) $display("%t: start bit error", $time);
            for (j = 0; j < 8; j = j + 1) begin
                #TICK_PERIOD;
                data[j] = tx;
            end
            #TICK_PERIOD;
            if (~tx) $display("%t: stop bit error", $time);
        end
    endtask

    uart_fifo_loopback dut (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tx(tx)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        rx = 1;
        send_data = 0;
        pass_cnt = 0;
        fail_cnt = 0;
        #10;
        reset = 0;

        send_data = 8'h32;
        SENDER_FOR_UART_RX(send_data);
        RECEIVER(receive_data);
        if (send_data == receive_data) $display("%t: PASS", $time);
        else
            $display(
                "%t: FAIL\tsend_data = %h,\treceive_data = %h",
                $time,
                send_data,
                receive_data
            );
        #TICK_PERIOD;

        $display("%t: RANDOM TEST START", $time);

        for (k = 0; k < 256; k = k + 1) begin
            send_data = $random % 256;
            SENDER_FOR_UART_RX(send_data);
            RECEIVER(receive_data);
            if (send_data == receive_data) begin
                $display("%t: PASS #%d\tdata = %h", $time, k, send_data);
                pass_cnt = pass_cnt + 1;
            end else begin
                $display("%t: FAIL\tsend_data = %h,\treceive_data = %h", $time,
                         send_data, receive_data);
                fail_cnt = fail_cnt + 1;
            end
        end

        #TICK_PERIOD;
        $display("%t: RANDOM TEST DONE\tPASS = %d\tFAIL = %d", $time, pass_cnt,
                 fail_cnt);
        //SENDER_FOR_UART_RX(8'h01);
        //SENDER_FOR_UART_RX(8'h02);

        #100;
        $stop;
    end

endmodule

module tb_uart_controller ();
    parameter TICK_PERIOD = 10 * (100_000_000 / 9600);

    reg clk, reset;
    reg tx_start;
    reg [7:0] tx_data;
    reg rx;
    wire rx_done, tx_busy, tx_done;
    wire tx;
    wire [7:0] rx_data;

    // 테스트용 신호
    integer i;
    //reg [7:0] o_data;

    //assign rx = tx;

    uart_controller dut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .rx(rx),
        .rx_data(rx_data),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .rx_done(rx_done),
        .tx(tx)
    );

    always #5 clk = ~clk;

    // task: uart tx start
    task UART_TX_START_TASK(input [7:0] i_tx_data);
        begin
            // UART TX
            // tx_start, tx_data 지정

            // tx_start를 1clk 동안 유지 -> pulse 신호 모사
            @(negedge clk);  // clk negedge에 맞게
            //@(negedge clk); // 다음 clk negedge까지 또 기다림
            tx_start = 1;
            tx_data  = i_tx_data;

            @(negedge clk);
            tx_start = 0;
            tx_data  = 0;

            wait (dut.U_UART_TX.tx_done); // 반 clk 만에 바로 tx_start 나옴
        end
    endtask

    // // tx 보내고 rx에서 받고 done까지 기다렸다가 다시 tx 시작하기 위해서
    // // tx Done 기다리는건 분리함
    // task WAIT_TX_DONE();
    //     begin
    //         //#(TICK_PERIOD * 10); // 시간으로 제어 -> 1clk 쉬었다가 감
    //         //@(dut.tx_done); // 이벤트로 제어
    //         wait (dut.U_UART_TX.tx_done); // 반 clk 만에 바로 tx_start 나옴
    //     end
    // endtask

    // rx를 모사해 tx의 값을 rx처럼 추출하는 sw
    // task UART_RX_TASK(output reg [7:0] o_data);
    //     integer j;
    //     begin
    //         wait (!tx);
    //         // start의 mid로
    //         #(TICK_PERIOD / 2);
    //         // start 값 검사
    //         if (tx == 1) begin
    //             $display("start bit error");
    //         end

    //         for (j = 0; j < 8; j = j + 1) begin
    //             // bit[i] 값 검사
    //             o_data[j] = tx;
    //             #TICK_PERIOD;
    //         end

    //         // stop
    //         #(TICK_PERIOD - 60_000);
    //         if (tx == 0) begin
    //             $display("stop bit error");
    //         end

    //         // stop의 end로
    //         //#(TICK_PERIOD / 2);
    //     end
    // endtask

    // tx를 모사해 rx에 tick 마다 데이터를 보내는 sw
    task SENDER_FOR_UART_RX(input [7:0] send_data);
        begin
            // start
            rx = 0;
            #TICK_PERIOD;
            // data
            for (i = 0; i < 8; i = i + 1) begin
                rx = send_data[i];
                #TICK_PERIOD;
            end

            // stop
            rx = 1;
            #TICK_PERIOD;
        end
    endtask



    initial begin
        clk = 0;
        reset = 1;
        tx_start = 0;
        tx_data = 0;
        rx = 1;
        #10;
        reset = 0;

        // for (i = 0; i < 256; i = i + 1) begin
        //     // init begin~end 특징: 끝나면 다음줄 끝나면 다음줄
        //     // 그럼 순서대로 tx 실행 -> rx 받기 -> done까지 기다림으로 task 쪼개기
        //     UART_TX_TASK(i);  // tx 보내기 시작
        //     // UART_RX_TASK(o_data);  // rx 받기
        //     // WAIT_TX_DONE();         // done까지 기다렸다가 다시 보내도록 타이밍 조치
        //     // if (i == o_data) $display("pass", i);
        //     // else begin
        //     //     $display("fail", i);
        //     //     $stop;
        //     // end
        // end

        UART_TX_START_TASK(8'h30);
        UART_TX_START_TASK(8'h31);

        SENDER_FOR_UART_RX(8'h32);
        SENDER_FOR_UART_RX(8'h33);

        SENDER_FOR_UART_RX(8'h00);
        SENDER_FOR_UART_RX(8'h01);

        #100;
        $stop;
    end
endmodule

module tb_top_data_modified ();
    parameter TICK_PERIOD = 10 * (100_000_000 / 9600);

    reg clk, reset;
    reg tx_start;
    reg [7:0] i_data;
    wire o_baud_tick;
    wire tx;

    baud_tick dut (
        .clk(clk),
        .reset(reset),
        .o_baud_tick(o_baud_tick)
    );

    uart_tx dut_uart (
        .clk(clk),
        .reset(reset),
        .i_baud_tick(o_baud_tick),
        .tx_start(tx_start),
        .i_data(i_data),
        .tx(tx)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        tx_start = 0;
        i_data = 8'b01010101;
        #10;
        reset = 0;

        #TICK_PERIOD;
        #5;
        tx_start = 1;
        #(TICK_PERIOD * 10);
        tx_start = 0;

        #(TICK_PERIOD * 30);
        i_data = 8'b00000000;

        #(TICK_PERIOD * 5);
        $stop;
    end
endmodule

module tb_uart_tx ();
    parameter TICK_PERIOD = 10 * (100_000_000 / 9600);

    reg clk, reset;
    reg tx_start;
    reg [7:0] i_data;
    wire o_baud_tick;
    wire tx;

    baud_tick dut (
        .clk(clk),
        .reset(reset),
        .o_baud_tick(o_baud_tick)
    );

    uart_tx dut_uart (
        .clk(clk),
        .reset(reset),
        .i_baud_tick(o_baud_tick),
        .tx_start(tx_start),
        .i_data(i_data),
        .tx(tx)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        tx_start = 0;
        i_data = 8'b01010101;
        #10;
        reset = 0;

        #TICK_PERIOD;
        #5;
        tx_start = 1;
        #(TICK_PERIOD * 10);
        tx_start = 0;

        #(TICK_PERIOD * 5);
        $stop;
    end
endmodule

module tb_baud_tick_gen ();

    reg clk, reset;
    wire o_baud_tick;

    baud_tick dut (
        .clk(clk),
        .reset(reset),
        .o_baud_tick(o_baud_tick)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #10;
        reset = 0;

        #(200_000);
        $stop;
    end
endmodule
