`timescale 1ns / 1ps

interface reg_interface;
    logic        clk;
    logic        reset;
    logic        enable;
    logic [31:0] d;
    logic [31:0] q;
endinterface

class transaction;
    bit             reset;
    rand bit        enable;
    rand bit [31:0] d;
    logic    [31:0] q;

    function void debug_print(string name);
        $display("%t: [%s] enable = %d, d = %d, q = %d", $time, name, enable,
                 d, q);
    endfunction
endclass

class generator;
    transaction tr, tr_2;

    mailbox #(transaction) gen2drv_mbox, gen2scb_mbox;

    event event2_gen;

    function new(mailbox#(transaction) gen2drv_mbox,
                 mailbox#(transaction) gen2scb_mbox, event event2_gen);
        this.gen2drv_mbox = gen2drv_mbox;
        this.gen2scb_mbox = gen2scb_mbox;
        this.event2_gen   = event2_gen;
    endfunction

    task run(int run_count);
        repeat (run_count) begin
            tr   = new();
            tr_2 = new();

            tr.randomize();
            tr_2.enable = tr.enable;
            tr_2.d = tr.d;
            tr_2.q = tr.q;

            gen2drv_mbox.put(tr);
            gen2scb_mbox.put(tr_2);
            tr.debug_print("GEN");
            @(event2_gen);
        end
    endtask

endclass

class driver;
    transaction tr;
    virtual reg_interface reg_vif;
    mailbox #(transaction) gen2drv_mbox;

    function new(virtual reg_interface reg_vif,
                 mailbox#(transaction) gen2drv_mbox);
        this.reg_vif = reg_vif;
        this.gen2drv_mbox = gen2drv_mbox;
    endfunction

    // reset만 1번 하는 태스크
    task preset();
        reg_vif.enable = 0;
        reg_vif.reset = 1;
        reg_vif.d = 0;
        @(negedge reg_vif.clk);
        @(negedge reg_vif.clk);
        reg_vif.reset = 0;
        @(negedge reg_vif.clk);
    endtask

    task run();
        forever begin
            gen2drv_mbox.get(tr);

            // posedge + 1ns 기다렸다가 drive
            @(posedge reg_vif.clk);
            #1;

            reg_vif.enable = tr.enable;
            reg_vif.d = tr.d;
            tr.debug_print("DRV");
        end
    endtask

endclass

class monitor;
    transaction tr;
    virtual reg_interface reg_vif;
    mailbox #(transaction) mon2scb_mbox;

    function new(virtual reg_interface reg_vif,
                 mailbox#(transaction) mon2scb_mbox);
        this.reg_vif = reg_vif;
        this.mon2scb_mbox = mon2scb_mbox;
    endfunction

    task run();
        forever begin
            @(negedge reg_vif.clk);
            tr = new();
            tr.enable = reg_vif.enable;
            tr.d = reg_vif.d;
            tr.q = reg_vif.q;

            mon2scb_mbox.put(tr);
            tr.debug_print("MON");
        end
    endtask
endclass

class scoreboard;
    transaction tr, tr_prev;
    mailbox #(transaction) mon2scb_mbox, gen2scb_mbox;

    event event2_gen;

    int pass_cnt = 0;
    int fail_cnt = 0;
    bit [31:0] d_prev = 0;
    // queue 버전
    // bit [31:0] prev_data[$];

    int first_flag = 0;

    function new(mailbox#(transaction) mon2scb_mbox,
                 mailbox#(transaction) gen2scb_mbox, event event2_gen);
        this.mon2scb_mbox = mon2scb_mbox;
        this.gen2scb_mbox = gen2scb_mbox;
        this.event2_gen   = event2_gen;
    endfunction

    task run();
        forever begin
            mon2scb_mbox.get(tr);
            if (first_flag) begin
                tr.debug_print("SCB");
                if (tr_prev.enable) begin
                    if (tr_prev.d == tr.q) begin
                        $display("%t PASS: D = %d, Q = %d", $time, tr_prev.d,
                                 tr.q);
                        pass_cnt++;
                    end else begin
                        $display("%t FAIL: D = %d, Q = %d", $time, tr_prev.d,
                                 tr.q);
                        fail_cnt++;
                    end
                end
            end else first_flag = 1;
            
            gen2scb_mbox.get(tr_prev);
            // if (tr.enable) d_prev = tr.d;
            // d_prev = prev_data.pop_front();
            // if (d_prev == tr.q) begin
            //     $display("%t PASS: D = %d, Q = %d", $time, d_prev, tr.q);
            //     pass_cnt++;
            // end else begin
            //     $display("%t FAIL: D = %d, Q = %d", $time, d_prev, tr.q);
            //     fail_cnt++;
            // end
            // if (tr.enable) prev_data.push_back(tr.d);
            // else prev_data.push_back(d_prev);

            ->event2_gen;
        end
    endtask

endclass

class environment;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;

    mailbox #(transaction) gen2drv_mbox, mon2scb_mbox, gen2scb_mbox;
    event event2_gen;

    function new(virtual reg_interface reg_vif);
        gen2drv_mbox = new;
        gen2scb_mbox = new;
        mon2scb_mbox = new;

        gen = new(gen2drv_mbox, gen2scb_mbox, event2_gen);
        drv = new(reg_vif, gen2drv_mbox);
        mon = new(reg_vif, mon2scb_mbox);
        scb = new(mon2scb_mbox, gen2scb_mbox, event2_gen);
    endfunction

    task run();
        drv.preset();

        fork
            gen.run(10);
            drv.run();
            mon.run();
            scb.run();
        join_any

        $display("__________________");
        $display("PASS: %d", scb.pass_cnt);
        $display("FAIL: %d", scb.fail_cnt);
        $display("__________________");

        #10;
        $finish;
    endtask
endclass

module tb_register_sv ();

    reg_interface reg_if ();
    environment env;

    register_sv dut (
        .clk(reg_if.clk),
        .reset(reg_if.reset),
        .enable(reg_if.enable),
        .d(reg_if.d),
        .q(reg_if.q)
    );

    always #5 reg_if.clk = ~reg_if.clk;

    initial begin
        reg_if.clk = 0;
        env = new(reg_if);
        env.run();
    end
endmodule
