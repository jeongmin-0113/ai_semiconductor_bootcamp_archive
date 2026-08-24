`timescale 1ns / 1ps

interface bus_if (
    input logic clk
);  // clk은 외부에서 port로 받음
    logic        valid;
    logic        we;
    logic [ 8:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;

    clocking cb @(posedge clk);
        default input #1step output #1ns;
        output valid, addr, wdata, we;
        input rdata;
    endclocking

    modport DUT(input clk, valid, we, addr, wdata, output rdata);
endinterface  //bus_if

module reg_file (
    bus_if.DUT b
);
    logic [31:0] mem[0:255];

    always_ff @(posedge b.clk) begin
        if (b.valid) begin
            $display(
                " [dut] = %t got we = %d, addr = %d, wdata = %h, rdata = %h",
                $time, b.we, b.addr, b.wdata, b.rdata);
            if (b.we) mem[b.addr] <= b.wdata;
            b.rdata <= b.wdata; // mem[b.addr];
        end
    end
endmodule

module tb_practice_oop_ex7 ();
    logic clk = 0;
    always #5 clk = ~clk;

    bus_if bif (clk);

    // 포트를 하나하나 연결하지 않아도 interface를 바로 넣을 수 있음
    reg_file dut (.b(bif));

    initial begin
        $display("[ex07] interface instance connects TB and DUT");
        bif.valid <= 0;

        // clocking block 이벤트
        @(bif.cb);
        bif.cb.valid <= 1;
        bif.cb.we    <= 1;
        bif.cb.addr  <= 8'h10;
        bif.cb.wdata    <= 32'haabbccdd;
        // $display("[TB] %t : drive schedule", $time);
        $display("[TB] %t : drive schedule", $time);

        @(bif.cb);
        bif.cb.valid <= 1;
        bif.cb.addr  <= 8'h11;
        bif.cb.wdata <= 32'h12345678;
        $display("[TB] %t : drive schedule", $time);

        @(bif.cb);
        bif.cb.valid <= 0;

        @(bif.cb);
        $display("[TB] %t : bif.cb.rdata = %d", $time, bif.cb.rdata);
        @(bif.cb);

        $finish;
    end

endmodule
