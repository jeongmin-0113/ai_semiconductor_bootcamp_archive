`timescale 1ns / 1ps

module tb_fifo ();

    reg clk, reset;
    reg [7:0] wData;
    reg push, pop;
    wire [7:0] rData;
    wire full, empty;

    fifo #(2) dut (
        .clk  (clk),
        .reset(reset),
        .wData(wData),
        .push (push),
        .pop  (pop),
        .rData(rData),
        .full (full),
        .empty(empty)
    );

    always #5 clk = ~clk;

    task TASK_PUSH(input [7:0] i_data);
        begin
            @(negedge clk);
            push  = 1;
            pop = 0;
            wData = i_data;
        end
    endtask

    task TASK_POP();
        begin
            @(negedge clk);
            push = 0;
            pop = 1;
        end
    endtask

    task TASK_PUSH_POP(input [7:0] i_data);
        begin
            @(negedge clk);
            {push, pop} = 2'b11;
            wData = i_data;
        end
    endtask

    initial begin
        clk   = 0;
        reset = 1;
        wData = 0;
        push  = 0;
        pop   = 0;
        #10;
        reset = 0;

        // 1. push only
        TASK_PUSH(8'h0a);
        TASK_PUSH(8'h0b);
        TASK_PUSH(8'h0c);
        TASK_PUSH(8'h0d);
        // full -> push 불가 확인
        TASK_PUSH(8'h0e);

        @(negedge clk);
        push = 0;
        #10;

        // 2. pop only
        TASK_POP();
        TASK_POP();
        TASK_POP();
        TASK_POP();
        // empty -> pop 불가 확인
        TASK_POP();

        @(negedge clk);
        pop = 0;
        #10;

        // 3-1. push pop 하기 전 empty 벗어나기
        TASK_PUSH(8'h00);

        // 3-2. push pop
        TASK_PUSH_POP(8'h01);
        TASK_PUSH_POP(8'h02);
        TASK_PUSH_POP(8'h03);
        TASK_PUSH_POP(8'h04);

        TASK_PUSH_POP(8'h05);
        TASK_PUSH_POP(8'h06);
        TASK_PUSH_POP(8'h07);
        TASK_PUSH_POP(8'h08);

        @(negedge clk);
        push = 0;

        // 3-3. pop -> empty로 끝내기
        TASK_POP();

        #10;
        $stop;

    end

endmodule
