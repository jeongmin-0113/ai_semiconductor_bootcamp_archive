`timescale 1ns / 1ps

module tb_gates();

    // 1 bit register
    reg a, b;

    // 1bit wire
    wire y0, y1, y2, y3, y4, y5, y6;

    // module name(gates)and instance name(dut)
	// like: int a (in C)
    gates dut (
        .a(a), // port name & input reg name is same -> ok!
        .b(b),
        .y0(y0),
        .y1(y1),
        .y2(y2),
        .y3(y3),
        .y4(y4),
        .y5(y5),
        .y6(y6)
    );  

    // init -> run in simulation 0ns
    initial begin
        a = 0;
        b = 0;

        #10; // run in 10ns (10ns delay)
        a = 0;
        b = 1;

        #10; // 20ns (10ns delay)
        a = 1;
        b = 0;

        #10; // 30ns (10ns delay)
        a = 1;
        b = 1;

        #10; // 40ns (10ns delay)
        // 30ns output with enough time last
        $stop; // stop simulation
    end

endmodule
