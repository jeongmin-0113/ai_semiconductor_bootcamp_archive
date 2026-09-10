`include "uvm_macros.svh"
import uvm_pkg::*;

interface fifo_if (input logic clk);
    // drv
    logic reset;
    logic i_push;
    logic i_pop;
    logic [7:0] i_data;
    // mon
    logic [7:0] o_data;
    logic full;
    logic empty;

    clocking drv_cb@(posedge clk);
        default input #1step output #1;
        output reset;
        output i_push;
        output i_pop;
        output i_data;
    endclocking

    clocking mon_cb@(posedge clk);
        default input #1step;
        input reset;
        input i_push;
        input i_pop;
        input i_data;
        input o_data;
        input full;
        input empty;
    endclocking

endinterface

// fifo seq item
class fifo_seq_item extends uvm_sequence_item;
    // stimulus
    bit reset;
    rand bit i_push;
    rand bit i_pop;
    rand bit [7:0] i_data;

    logic o_data;
    logic full;
    logic empty;

    // constraint
    
    function new(string name = "fifo_seq_item");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(fifo_seq_item)
        `uvm_field_int(reset, UVM_DEFAULT)
        `uvm_field_int(i_push, UVM_DEFAULT)
        `uvm_field_int(i_pop, UVM_DEFAULT)
        `uvm_field_int(i_data, UVM_DEFAULT)
        `uvm_field_int(o_data, UVM_DEFAULT)
        `uvm_field_int(full, UVM_DEFAULT)
        `uvm_field_int(empty, UVM_DEFAULT)
    `uvm_object_utils_end

    function string item2string();
        return $sformatf(
            "reset = %d, i_push = %d, i_pop = %d, i_data = %d, o_data = %d, full = %d, empty = %d",
            reset, i_push, i_pop, i_data, o_data, full, empty
        );
    endfunction
endclass

// fifo sequence
class fifo_sequence extends uvm_sequence#(fifo_seq_item);
    `uvm_object_utils(fifo_sequence)

    fifo_seq_item f_item;

    function new (string name = "fifo_seq");
        super.new(name);
    endfunction

    task body();
        repeat (100) begin
            f_item = fifo_seq_item::type_id::create("f_item");

            start_item(f_item);
                if (!f_item.randomize()) begin
                   `uvm_fatal(get_type_name(), "fifo seq item randomize error") 
                end
            finish_item(f_item);
        end
    endtask
endclass

// fifo driver
class fifo_driver extends uvm_driver#(fifo_seq_item);
    `uvm_component_utils(fifo_driver)

    virtual fifo_if f_if;
    fifo_seq_item f_item;

    function new (string name = "fifo_drv", uvm_component c = null);
        super.new(name, c);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual fifo_if)::get(this, "", "f_if", f_if)) begin
           `uvm_fatal(get_name(), "unable to access fifo interface") 
        end
    endfunction

    task setup_initial_value();
        f_if.drv_cb.reset <= 1;
        f_if.drv_cb.i_push <= 0;
        f_if.drv_cb.i_pop <= 0;
        f_if.drv_cb.i_data <= 0;
        @(posedge f_if.clk);
    endtask

    task run_phase (uvm_phase phase);
        setup_initial_value();

        forever begin
            seq_item_port.get_next_item(f_item);

            @(f_if.drv_cb);
            f_if.drv_cb.reset <= 0;
            f_if.drv_cb.i_push <= f_item.i_push;
            f_if.drv_cb.i_pop <= f_item.i_pop;
            f_if.drv_cb.i_data <= f_item.i_data;

            seq_item_port.item_done();
        end
    endtask
endclass

// fifo monitor
class fifo_monitor extends uvm_monitor;
    `uvm_component_utils(fifo_monitor)

    virtual fifo_if f_if;
    fifo_seq_item f_item;
    uvm_analysis_port #(fifo_seq_item) send;

    function new (string name = "fifo_mon", uvm_component c = null);
        super.new(name, c);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual fifo_if)::get(this, "", "f_if", f_if)) begin
            `uvm_fatal(get_name(), "unable to access fifo interface")
        end

        send = new("SEND", this);
    endfunction

    task run_phase (uvm_phase phase);
        super.run_phase(phase);

        forever begin
            f_item = fifo_seq_item::type_id::create("f_item");

            @(f_if.mon_cb);
            f_item.reset = f_if.mon_cb.reset;
            f_item.i_push = f_if.mon_cb.i_push;
            f_item.i_pop = f_if.mon_cb.i_pop;
            f_item.i_data = f_if.mon_cb.i_data;
            f_item.o_data = f_if.mon_cb.o_data;
            f_item.full = f_if.mon_cb.full;
            f_item.empty = f_if.mon_cb.empty;

            send.write(f_item);
        end
    endtask
endclass

// fifo scoreboard
class fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fifo_scoreboard)
    
    uvm_analysis_imp#(fifo_seq_item, fifo_scoreboard) recv;

    reg [7:0] compare_buffer[0:15];
    reg [3:0] push_cnt, pop_cnt;
    
    bit buf_empty, buf_full;
    reg buf_full_reg, buf_empty_reg;  // 현재 time slot의 full/empty 판단에 쓸 값

    integer pass_cnt, fail_cnt;

    function new (string name = "fifo_scb", uvm_component c = null);
        super.new(name, c);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        recv = new("RECV", this);
    endfunction

    function void write(fifo_seq_item f_item);
        buf_full_reg = buf_full;
        buf_empty_reg = buf_empty;

        if (f_item.push) begin
            // full이 아닐때 -> push 작동 확인
            if (!f_item.full) begin
                compare_buffer[push_cnt] = f_item.i_data;
                `uvm_info("SCB", $sformatf("PUSH: %s", f_item.item2string()), UVM_HIGH)
                push_cnt = push_cnt + 1;
                pass_cnt = pass_cnt + 1;
                if (buf_empty_reg) buf_empty = 0;
                if (push_cnt == pop_cnt) begin
                    `uvm_info("SCB", "FULL", UVM_HIGH)
                    buf_full = 1;
                end
            end else begin
                // full일 때 -> buf_full과 full 모두 1이면 PASS
                if (buf_full_reg) begin
                    `uvm_info("SCB", $sformatf("FULL PASS: dut full = %d, buf full = %d", f_item.full, buf_full), UVM_HIGH)
                    pass_cnt = pass_cnt + 1;
                end else begin
                    `uvm_error("SCB", $sformatf("FULL FAIL: dut full = %d, buf full = %d", f_item.full, buf_full))
                    fail_cnt = fail_cnt + 1;
                end
            end
        end

        if (f_item.pop) begin
            // empty가 아닐 때 -> pop 작동 확인
            if (!f_item.empty) begin
                if (compare_buffer[pop_cnt] == f_item.o_data) begin
                    `uvm_info("SCB", $sformatf("POP PASS: %s", f_item.item2string()), UVM_HIGH)
                    pop_cnt  = pop_cnt + 1;
                    pass_cnt = pass_cnt + 1;
                    if (buf_full_reg) buf_full = 0;
                    if (push_cnt == pop_cnt) begin
                        `uvm_info("SCB", "EMPTY", UVM_HIGH)
                        buf_empty = 1;
                    end
                end else begin
                    `uvm_error("SCB", $sformatf("POP FAIL: expected = %d, real = %d", compare_buffer[pop_cnt], f_item.o_data))
                    fail_cnt = fail_cnt + 1;
                end
            end else begin
                // empty일 때 -> buf_empty와 empty가 모두 1이면 PASS
                if (buf_empty_reg) begin
                    `uvm_info("SCB", $sformatf("EMPTY PASS: dut empty = %d, buf empty = %d", f_item.empty, buf_empty), UVM_HIGH)
                    pass_cnt = pass_cnt + 1;
                end else begin
                    `uvm_error("SCB", $sformatf("EMPTY FAIL: dut empty = %d, buf empty = %d", f_item.empty, buf_empty))
                    fail_cnt = fail_cnt + 1;
                end
            end
        end
    endfunction

endclass

// fifo coverage
class fifo_coverage extends uvm_subscriber#(fifo_seq_item);
    `uvm_component_utils(fifo_coverage)

    fifo_seq_item f_item;

    covergroup fifo_cg;
        cp_i_push: coverpoint f_item.i_push {
            bins push = {1};
            bins not_push = {0};
        }
        cp_i_pop: coverpoint f_item.i_pop {
            bins pop = {1};
            bins not_pop = {0};
        }
        cp_i_data: coverpoint f_item.i_data {
            bins range_0_to_255[] = {[0:255]};
        }
        cp_o_data: coverpoint f_item.o_data {
            bins range_0_to_255[] = {[0:255]};
        }
        cp_full: coverpoint f_item.full {
            bins full = {1};
            bins not_full = {0};
        }
        cp_empty: coverpoint f_item.empty {
            bins empty = {1};
            bins not_empty = {0};
        }
        cx_push_pop_i_data: cross cp_i_push, cp_i_pop, cp_i_data;
    endgroup

    function new (string name = "fifo_cvg", uvm_component c = null);
        super.new(name, c);

        fifo_cg = new();
    endfunction

    function void write(fifo_seq_item t);
        f_item = t;
        fifo_cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("CVG", 
            $sformatf(
                "=== Coverage Report ===\nOverall\t=\t%.1f%%\ni_push\t=\t%.1f%%\ni_pop\t=\t%.1f%%\ni_data\t=\t%.1f%%\no_data\t=\t%.1f%%\nfull\t=\t%.1f%%\nempty\t=\t%.1f%%\n", 
                fifo_cg.get_inst_coverage(), 
                fifo_cg.cp_i_push.get_coverage(),
                fifo_cg.cp_i_pop.get_coverage(),
                fifo_cg.cp_i_data.get_coverage(),
                fifo_cg.cp_o_data.get_coverage(),
                fifo_cg.cp_full.get_coverage(),
                fifo_cg.cp_empty.get_coverage()
            ), UVM_NONE
        );
    endfunction
endclass

// fifo agent (sqr + drv + mon)
class fifo_agent extends uvm_agent;
    `uvm_component_utils(fifo_agent)

    uvm_sequencer#(fifo_seq_item) sqr;
    fifo_driver drv;
    fifo_monitor mon;

    function new(string name = "fifo_agt", uvm_component c = null);
        super.new(name, c);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        sqr = uvm_sequencer#(fifo_seq_item)::type_id::create("fifo_sqr", this);
        drv = fifo_driver::type_id::create("fifo_drv", this);
        mon = fifo_monitor::type_id::create("fifo_mon", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
endclass

// fifo env (agt + scb + cvg)
class fifo_env extends uvm_env;
    `uvm_component_utils(fifo_env)

    fifo_agent agt;
    fifo_scoreboard scb;
    fifo_coverage cvg;

    function new(string name = "fifo_env", uvm_component c= null);
        super.new(name, c);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agt = fifo_agent::type_id::create("fifo_agt", this);
        scb = fifo_scoreboard::type_id::create("fifo_scb", this);
        cvg = fifo_coverage::type_id::create("fifo_cvg", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        agt.mon.send.connect(scb.recv);
        agt.mon.send.connect(cvg.analysis_export);
    endfunction
endclass

// fifo test (env + seq)
class fifo_test extends uvm_test;
    `uvm_component_utils(fifo_test)

    fifo_env env;
    fifo_sequence seq;

    function new(string name = "fifo_test", uvm_component c = null);
        super.new(name, c);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = fifo_env::type_id::create("fifo_env", this);
        seq = fifo_sequence::type_id::create("fifo_seq", this);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        phase.raise_objection(this);
        
        seq.start(env.agt.sqr);
        @(posedge env.agt.drv.f_if.clk);

        phase.drop_objection(this);
    endtask
endclass

module tb_fifo ();
    
    logic clk;
    always #5 clk = ~clk;

    fifo_if f_if(clk);

    fifo #(4) dut (
        .clk(f_if.clk),
        .reset(f_if.reset),
        .i_push(f_if.i_push),
        .i_pop(f_if.i_pop),
        .i_data(f_if.i_data),
        .o_data(f_if.o_data),
        .full(f_if.full),
        .empty(f_if.empty)
    );

    initial begin
        $fsdbDumpfile("wave.fsdb");
        $fsdbDumpvars(0);
    end

    initial begin
        // interface -> db enroll
        uvm_config_db#(virtual fifo_if)::set(null, "*", "f_if", f_if);

        // run test
        run_test("fifo_test");

        $finish;
    end

endmodule
