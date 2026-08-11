`timescale 1ns / 1ps

module tb_fifo ();

    reg clk, reset;
    reg [7:0] wData;
    reg push, pop;
    wire [7:0] rData;
    wire full, empty;

    integer i;

    reg [7:0] compare_buffer[0:3];
    reg [1:0] push_cnt, pop_cnt;
    integer pass_cnt, fail_cnt;

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
            pop   = 0;
            wData = i_data;
        end
    endtask

    task TASK_POP();
        begin
            @(negedge clk);
            push = 0;
            pop  = 1;
        end
    endtask

    task TASK_PUSH_POP(input [7:0] i_data);
        begin
            @(negedge clk);
            {push, pop} = 2'b11;
            wData = i_data;
        end
    endtask
    reg buf_full, buf_empty;
    reg buf_full_reg, buf_empty_reg;  // 현재 time slot의 full/empty 판단에 쓸 값

    initial begin
        clk = 0;
        reset = 1;
        wData = 0;
        push = 0;
        pop = 0;
        i = 0;
        push_cnt = 0;
        pop_cnt = 0;
        pass_cnt = 0;
        fail_cnt = 0;
        buf_full = 0;
        buf_empty = 1;
        buf_full_reg = buf_full;
        buf_empty_reg = buf_empty;
        #10;
        reset = 0;

        // // 1. push only
        // TASK_PUSH(8'h0a);
        // TASK_PUSH(8'h0b);
        // TASK_PUSH(8'h0c);
        // TASK_PUSH(8'h0d);
        // // full -> push 불가 확인
        // TASK_PUSH(8'h0e);

        // @(negedge clk);
        // push = 0;
        // #10;

        // // 2. pop only
        // TASK_POP();
        // TASK_POP();
        // TASK_POP();
        // TASK_POP();
        // // empty -> pop 불가 확인
        // TASK_POP();

        // @(negedge clk);
        // pop = 0;
        // #10;

        // // 3-1. push pop 하기 전 empty 벗어나기
        // TASK_PUSH(8'h00);

        // // 3-2. push pop
        // TASK_PUSH_POP(8'h01);
        // TASK_PUSH_POP(8'h02);
        // TASK_PUSH_POP(8'h03);
        // TASK_PUSH_POP(8'h04);

        // TASK_PUSH_POP(8'h05);
        // TASK_PUSH_POP(8'h06);
        // TASK_PUSH_POP(8'h07);
        // TASK_PUSH_POP(8'h08);

        // @(negedge clk);
        // push = 0;

        // // 3-3. pop -> empty로 끝내기
        // TASK_POP();
        // #10;
        // pop = 0;
        // #10;


        $display("%t: RANDOM TEST START", $time);



        for (i = 0; i < 256; i = i + 1) begin
            @(posedge clk);
            #1;

            buf_full_reg = buf_full;
            buf_empty_reg = buf_empty;

            // 0~1 사이의 랜덤 수를 만듦
            push = $random % 2;
            pop = $random % 2;

            // 0~255 사이의 랜덤 수를 만듦
            wData = $random % 256;

            // display: non blocking 만나면 non blocking보다 먼저 처리됨
            // strobe: time block의 마지막에 실행됨
            $display("%t: push = %d,\tpop = %d,\twdata = %d", $time, push, pop,
                     wData);


            // monitor & score negedge에서
            @(negedge clk);
            // 동시에 발생할 수 있으니 다중 if

            if (push) begin
                // full이 아닐때 -> push 작동 확인
                if (!full) begin
                    compare_buffer[push_cnt] = wData;
                    $display("%t PUSH:\tcompare_buffer = %d", $time,
                             compare_buffer[push_cnt]);
                    push_cnt = push_cnt + 1;
                    pass_cnt = pass_cnt + 1;
                    if (buf_empty_reg) buf_empty = 0;
                    if (push_cnt == pop_cnt) begin
                        $display(
                            "%t FULL:\tcompare_buffer = {\t%d,\t%d,\t%d,\t%d}",
                            $time, compare_buffer[0], compare_buffer[1],
                            compare_buffer[2], compare_buffer[3]);
                        buf_full = 1;
                    end
                end else begin
                    // full일 때 -> buf_full과 full 모두 1이면 PASS
                    if (buf_full_reg) begin
                        $display("%t PASS:\tdut full = %d\tbuf full = %d",
                                 $time, full, buf_full_reg);
                        pass_cnt = pass_cnt + 1;
                    end else begin
                        $display("%t FAIL:\tdut full = %d\tbuf full = %d",
                                 $time, full, buf_full_reg);
                        fail_cnt = fail_cnt + 1;
                    end
                end
            end

            if (pop) begin
                // empty가 아닐 때 -> pop 작동 확인
                if (!empty) begin
                    if (compare_buffer[pop_cnt] == rData) begin
                        $display(
                            "%t PASS!:\tcompare_data = %d,\trData = %d,\tpop = %d,\tempty = %d",
                            $time, compare_buffer[pop_cnt], rData, pop, empty);
                        pop_cnt  = pop_cnt + 1;
                        pass_cnt = pass_cnt + 1;
                        if (buf_full_reg) buf_full = 0;
                        if (push_cnt == pop_cnt) begin
                            $display("%t EMPTY:\t", $time,);
                            buf_empty = 1;
                        end
                    end else begin
                        $display(
                            "%t FAIL!:\tcompare_data = %d,\trData = %d,\tpop = %d,\tempty = %d",
                            $time, compare_buffer[pop_cnt], rData, pop, empty);
                        fail_cnt = fail_cnt + 1;
                    end
                end else begin
                    // empty일 때 -> buf_empty와 empty가 모두 1이면 PASS
                    if (buf_empty_reg) begin
                        $display("%t PASS:\tdut empty = %d\tbuf empty = %d",
                                 $time, empty, buf_empty_reg);
                        pass_cnt = pass_cnt + 1;
                    end else begin
                        $display("%t FAIL:\tdut empty = %d\tbuf empty = %d",
                                 $time, empty, buf_empty_reg);
                        fail_cnt = fail_cnt + 1;
                    end
                end
            end
        end

        $strobe("%t: RANDOM TEST END\tpass = %d,\tfail = %d", $time, pass_cnt,
                fail_cnt);

        $stop;

    end

endmodule
