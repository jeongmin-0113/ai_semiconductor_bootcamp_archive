`timescale 1ns / 1ps

// interface: to connect object - module, module - module
// 근데 왜 꼭 interface가 있어야 함? 바로 dut에 drive하면 안됨?
// dut - interface - transaction - generator 연결
// interface가 dut의 포트 이름 다 가지고 있고 개별 데이터를 주고받는게 아니라 한번에 interface 객체로 주고받기가 가능함
interface adder_interface;
    logic [7:0] a;
    logic [7:0] b;
    logic       mode;
    logic [7:0] s;
    logic       c;
endinterface

// stimulus + 데이터 전달자
// 데이터를 운반하는 역할. 
// stimulus 생성하는 애한테 a,b,mode 주고
// 검사하고 관찰하는 애한테 s, c 줄거임
class transaction;
    // x/z 를 굳이 생성하지 않고 2 state만 쓸거면 logic 쓸 필요 없음
    // rand: random variable
    // randc: 한번씩 무조건 생성하고 싶을 때
    // rand + randomize task -> 랜덤하게 stimulus 생성 가능
    // 무조건 random 값은 아님. 내가 임의의 값을 drive할 수도 있음
    // rand 안붙은애들은 randomize할 때도 random 값 안생김
    rand bit [7:0] a;
    rand bit [7:0] b;
    rand bit       mode;

    // 출력값은 random 필요가 없음
    // 어짜피 dut의 출력을 받을거니까...
    logic    [7:0] s;
    logic          c;

    // 제약 조건
    // constraint in_range {
    //     a > 128;
    //     b > 250;
    //     a inside {[1:127]};
    // }

    // constraint mode_distribute {
    //     if (mode == 0) b inside {0,1,2,3,15,20,127};
    //     else b > 128;
    // }

    constraint mode_dist2 {
        mode dist {
            0 :/ 90,
            1 :/ 10
        };
    }

    function void debug_print(string name);
        $display("%t: [%s] a = %d, b = %d, mode = %d, s = %d, c = %d", $time,
                 name, a, b, mode, s, c);
    endfunction
endclass

// sequencer/generator: stimulus 실제 생성 
class generator;
    // 클래스 아직 생성 안됨
    // transaction 클래스 타입의 변수를 나중에 만들겠다! 자리만 맡아둔 것
    // transaction tr이라는 이름으로 메모리에 자리 할당함 (**아직 실체화되지 않음)
    // handler (메모리에 tr이라는 이름으로 접근 가능한 transaction 자리 == 메모리 주소임) -> generator의 func new가 불릴 때 동적 할당하겠다
    transaction tr;
    // 다른 class와 공유할 메일박스 생성
    // 클래스: transaction
    mailbox #(transaction) gen2drv_mbox;

    event event2gen;


    function new(mailbox#(transaction) gen2drv_mbox, event event2gen);
        this.gen2drv_mbox = gen2drv_mbox;
        this.event2gen = event2gen;
    endfunction


    task run(int run_count);
        // new: transaction 객체를 실제로 메모리에 실체화(동적 할당)하는 함수
        // 약간 init 함수 비슷한거임
        repeat (run_count) begin
            tr = new;  // run될 때마다 새 transaction이 매번 생성됨

            // rand 키워드가 붙은 stimulus(a,b,mode)에 랜덤값 생성
            tr.randomize();

            // 메일박스에 transaction 타입 인스턴스를 넣기
            gen2drv_mbox.put(tr);
            // $display("%t: gen tr.a = %d, tr.b = %d, tr.mode = %d", $time, tr.a,
            //          tr.b, tr.mode);

            tr.debug_print("gen");
            @(event2gen);
            
        end
        $display("end gen");
    endtask
endclass

// driver: 값을 dut에 drive
class driver;
    // 가상 인터페이스, virtual interface
    // handler와 비슷한 역할 - 아직 tb_adder의 adder_if와 연결되지 않음
    // new에서 생성되자마자 같이 연결해버리자
    virtual adder_interface vif;
    // virtual 키워드
    // generator는 소프트웨어. 모듈이 아니다. 하드웨어에 실체화되어있지 않다
    // 하드웨어에 실체화되어있는 것 - 소프트웨어로 연결할 때 virtual 키워드 사용해야 함
    // 하드웨어끼리, 소프트웨어끼리는 virtual 안해도 된다

    mailbox #(transaction) gen2drv_mbox;
    transaction tr;

    event event2gen;

    function new(mailbox#(transaction) gen2drv_mbox,
                 virtual adder_interface vif, event event2gen);
        this.gen2drv_mbox = gen2drv_mbox;
        this.vif          = vif;
        this.event2gen    = event2gen;
    endfunction

    task run();
        forever begin
            gen2drv_mbox.get(tr);
            // $display("%t: drv tr.a = %d, tr.b = %d, tr.mode = %d", $time, tr.a,
            //                      tr.b, tr.mode);
            tr.debug_print("drv");

            vif.a = tr.a;
            vif.b = tr.b;
            vif.mode = tr.mode;
            #10;
            ->event2gen;
        end
        $display("end drv");
    endtask
endclass

class monitor;
    transaction tr;
    virtual adder_interface vif;
    mailbox #(transaction) mon2scb_mbox;


    function new(mailbox#(transaction) mon2scb_mbox,
                 virtual adder_interface vif);

        this.mon2scb_mbox = mon2scb_mbox;
        this.vif = vif;
    endfunction

    task run();
        forever begin
            #1;
            tr = new;

            tr.a = vif.a;
            tr.b = vif.b;
            tr.mode = vif.mode;
            tr.s = vif.s;
            tr.c = vif.c;

            tr.debug_print("mon");
            mon2scb_mbox.put(tr);
            #9;
        end
    endtask
endclass

class scoreboard;
    mailbox #(transaction) mon2scb_mbox;
    transaction tr;

    bit [7:0] compare_s;
    bit compare_c;
    int pass_cnt, fail_cnt, test_cnt;

    function new(mailbox#(transaction) mon2scb_mbox);
        this.mon2scb_mbox = mon2scb_mbox;
        pass_cnt = 0;
        fail_cnt = 0;
        test_cnt = 0;
    endfunction

    task run();
        forever begin
            mon2scb_mbox.get(tr);
            tr.debug_print("scb");
            test_cnt++;
            {compare_c, compare_s} = (tr.mode) ? tr.a - tr.b : tr.a + tr.b;

            if ((compare_c == tr.c) && (compare_s == tr.s)) begin
                pass_cnt++;
                $display("%t: PASS", $time);
                // $display(
                //     "%t PASS: tr carry = %d, sum = %d, comp carry = %d, sum = %d",
                //     $time, tr.c, tr.s, compare_c, compare_s);
            end else begin
                fail_cnt++;
                $display("%t: FAIL", $time);
                // $display(
                //     "%t FAIL: tr carry = %d, sum = %d, comp carry = %d, sum = %d",
                //     $time, tr.c, tr.s, compare_c, compare_s);
            end
        end
    endtask

    task done();
        $display("** total = %4d **", test_cnt);
        $display("** PASS  = %4d **", pass_cnt);
        $display("** FAIL  = %4d **", fail_cnt);
    endtask

endclass

class environment;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;

    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;
    
    event event2gen;

    function new(virtual adder_interface vif);
        gen2drv_mbox = new();
        gen = new(gen2drv_mbox, event2gen);
        drv = new(gen2drv_mbox, vif, event2gen);

        mon2scb_mbox = new();
        mon = new(mon2scb_mbox, vif);
        scb = new(mon2scb_mbox);
    endfunction

    task run();
        // fork ~ join 병렬 실행시에는 지연 의미가 없음
        // 왜? 순서가 정해져있지 않음. 동시 실행임
        fork
            gen.run(20);
            drv.run();
            mon.run();
            scb.run();
        join_any
        $display("________________________");
        scb.done();
    endtask
endclass

module tb_adder ();
    environment env;
    adder_interface adder_if ();

    adder dut (
        .a   (adder_if.a),
        .b   (adder_if.b),
        .mode(adder_if.mode),
        .s   (adder_if.s),
        .c   (adder_if.c)
    );

    initial begin
        env = new(.vif(adder_if));

        env.run();

        $stop;
    end

endmodule
