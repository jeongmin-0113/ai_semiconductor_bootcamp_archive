`timescale 1ns / 1ps

`include "uvm_macros.svh"  // define uvm_* macro
import uvm_pkg::*;  // uvm pkg 내부 모든 모듈 및 클래스 불러오기
// 빨간줄: uvm_macros 파일을 못찾음 - 당연. 로컬에 없음

interface adder_if (
    input bit clk
);

    logic [7:0] a;
    logic [7:0] b;
    logic [8:0] y;  // result

endinterface

// transaction -> seq_item from uvm_sequence_item
class seq_item extends uvm_sequence_item;
    rand bit [7:0] a;
    rand bit [7:0] b;
    bit [8:0] y;

    function new(string name = "ADDER_Seq_item");
        super.new(name); // uvm_sequenec_item class 초기화
    endfunction

    // 백풀? 백프리?한다
    // uvm에서 제공하는 매크로
    // 매크로에는 ; 쓰지 않음
    `uvm_object_utils_begin(seq_item)
        `uvm_field_int(a, UVM_DEFAULT)
        `uvm_field_int(b, UVM_DEFAULT)
        `uvm_field_int(y, UVM_DEFAULT)
    `uvm_object_utils_end
endclass

module tb_adder_uvm ();
    bit clk;
    adder_if aif(clk);

    always #5 clk = ~clk;

    adder dut (
        .a(),
        .b(),
        .y()
    );
endmodule
