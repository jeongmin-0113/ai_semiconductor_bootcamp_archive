`timescale 1ns / 1ps

`timescale 1ns / 1ps

module tb_uart ();
    reg        clk;
    reg        rstn;

    // tx internal signal
    reg  [7:0] tx_data;
    reg        tx_start;
    wire       tx_busy;
    wire       tx_done;

    // tx external port
    wire       tx;

    // rx internal signal
    wire [7:0] rx_data;
    wire       rx_done;

    // rx external port
    reg        rx;
    wire       loop;

    uart #(
        .CLK_FREQ (100_000_000),
        .BAUD_RATE(115_200)
    ) dut (
        .clk (clk),
        .rstn(rstn),

        // tx internal signal
        .tx_data (tx_data),
        .tx_start(tx_start),
        .tx_busy (tx_busy),
        .tx_done (tx_done),

        // tx external port
        .tx(loop),

        // rx internal signal
        .rx_data(rx_data),
        .rx_done(rx_done),

        // rx external port
        .rx(loop)
    );

    task uart_writeData(logic [7:0] w_data);
        @(posedge clk);
        wait (tx_busy == 1'b0); // busy가 아닐때까지 기다리기
        tx_data <= w_data;
        tx_start <= 1;
        @(posedge clk);
        tx_start <= 0;
        $display("[%t] tx done: data = %x", $time, tx_data); // data 16진수 출력
    endtask

    task uart_readData();

    endtask

    always #5 clk = ~clk;

    logic [7:0] uart_data;
    initial begin
        clk  = 0;
        rstn = 0;
        repeat (3) @(posedge clk);
        rstn = 1;
        repeat (3) @(posedge clk);

        uart_writeData(8'haa);
        uart_writeData(8'h55);
        uart_writeData(8'hcc);
        uart_writeData(8'h33);
    end
endmodule