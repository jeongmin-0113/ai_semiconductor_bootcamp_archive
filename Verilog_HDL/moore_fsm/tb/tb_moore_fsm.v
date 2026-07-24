`timescale 1ns / 1ps

module tb_moore_fsm();

    parameter delay_fsm = 20;

    reg clk, reset;
    reg [2:0] sw;
    wire [2:0] led;

    fsm_moore_led03 dut (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .led(led)
    );

    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        reset = 1;
        sw = 3'b000;
        #10;
        reset = 0;
        
        // 정상동작
        sw = dut.S1;
        #delay_fsm;

        sw = dut.S2;
        #delay_fsm;

        sw = dut.S3;
        #delay_fsm;

        sw = dut.S4;
        #delay_fsm;

        sw = dut.S0;
        #delay_fsm;

        sw = dut.S4;
        #delay_fsm;

        sw = dut.S1;
        #delay_fsm;

        // 존재하지 않는 루트 -> 상태 유지
        sw = dut.S3;
        #delay_fsm;

        sw = dut.S4;
        #delay_fsm;
        $stop;
    end
endmodule
