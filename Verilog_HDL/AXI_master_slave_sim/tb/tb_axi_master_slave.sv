`timescale 1ns / 1ps


module tb_axi_master_slave ();

    logic ACLK, ARESETn;

    // internal signal
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic        write;
    logic        transfer;
    logic        ready;

    // aw channel
    logic [31:0] AWADDR;
    logic        AWVALID;
    logic        AWREADY;

    // w channel
    logic [31:0] WDATA;
    logic        WVALID;
    logic        WREADY;

    // b channel
    logic [ 1:0] BRESP;
    logic        BVALID;
    logic        BREADY;

    // ar channel
    logic [31:0] ARADDR;
    logic        ARVALID;
    logic        ARREADY;

    // r channel
    logic [31:0] RDATA;
    logic        RVALID;
    logic        RREADY;
    logic [ 1:0] RRESP;

    axi_master dut_master (.*);
    axi_slave dut_slave (.*);

    always #5 ACLK = ~ACLK;

    task axi_write(logic [31:0] w_addr, logic [31:0] w_data);
        @(posedge ACLK);
        addr = w_addr;
        wdata = w_data;
        write = 1;
        transfer = 1;
        @(posedge ACLK);
        transfer = 1'b0;
        wait (ready);
        @(posedge ACLK);
        $display("[%0t] AXI WRITE: WADDR = %0h,\tWDATA = %0h", $time, addr, wdata);
    endtask  //axi_write

    task axi_read(logic [31:0] r_addr);
        @(posedge ACLK);
        addr = r_addr;
        write = 0;
        transfer = 1'b1;
        @(posedge ACLK);
        transfer = 1'b0;
        wait (ready);
        @(posedge ACLK);
        $display("[%0t] AXI READ : RADDR = %0h,\tRDATA = %0h", $time, addr, rdata);
    endtask

    initial begin
        ACLK = 0;
        ARESETn = 0;
        // 3 clk후 reset 해제
        repeat (3) @(posedge ACLK);
        ARESETn = 1;

        @(posedge ACLK);
        axi_write(32'h00, 32'h11111111);
        axi_write(32'h04, 32'h22222222);
        axi_write(32'h08, 32'h33333333);
        axi_write(32'h0c, 32'h44444444);
        @(posedge ACLK);
        axi_read(32'h00);
        axi_read(32'h04);
        axi_read(32'h08);
        axi_read(32'h0c);

        #100;
        $finish;
    end
endmodule
