`timescale 1ns / 1ps

module tb_AXI_Lite_template ();

    parameter integer C_S00_AXI_DATA_WIDTH = 32;
    parameter integer C_S00_AXI_ADDR_WIDTH = 4;

    logic s00_axi_aclk;
    logic s00_axi_aresetn;
    logic [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr;
    logic [2 : 0] s00_axi_awprot;
    logic s00_axi_awvalid;
    logic s00_axi_awready;
    logic [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata;
    logic [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb;
    logic s00_axi_wvalid;
    logic s00_axi_wready;
    logic [1 : 0] s00_axi_bresp;
    logic s00_axi_bvalid;
    logic s00_axi_bready;
    logic [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr;
    logic [2 : 0] s00_axi_arprot;
    logic s00_axi_arvalid;
    logic s00_axi_arready;
    logic [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata;
    logic [1 : 0] s00_axi_rresp;
    logic s00_axi_rvalid;
    logic s00_axi_rready;

    myip_v1_0 #(C_S00_AXI_DATA_WIDTH, C_S00_AXI_ADDR_WIDTH) dut (.*);

    always #5 s00_axi_aclk = ~s00_axi_aclk;

    // master의 동작을 모사하는 task 만들어 slave에 데이터 읽기 / 쓰기
    task axi_write(logic [31:0] w_addr, logic [31:0] w_data);
        @(posedge s00_axi_aclk);
        // aw
        s00_axi_awaddr  <= w_addr;
        s00_axi_awvalid <= 1'b1;
        // w
        s00_axi_wdata   <= w_data;
        s00_axi_wvalid  <= 1'b1;
        s00_axi_wstrb   <= 4'b1111;
        // b
        s00_axi_bready  <= 1'b1;

        wait (s00_axi_awready & s00_axi_wready);
        @(posedge s00_axi_aclk);
        s00_axi_awvalid <= 1'b0;
        s00_axi_wvalid  <= 1'b0;

        wait (s00_axi_bvalid);
        // @(posedge s00_axi_aclk);
        @(posedge s00_axi_aclk);
        s00_axi_bready <= 1'b0;

        $display("[%0t] AXI WRITE: WADDR = 0x%0h,\tWDATA = 0x%0h", $time,
                 s00_axi_awaddr, s00_axi_wdata);
    endtask

    logic [31:0] rdata;
    task axi_read(logic [31:0] r_addr);

        @(posedge s00_axi_aclk);
        // ar
        s00_axi_araddr  <= r_addr;
        s00_axi_arvalid <= 1'b1;

        // r
        s00_axi_rready  <= 1'b1;

        wait (s00_axi_arready);
        @(posedge s00_axi_aclk);
        s00_axi_arvalid <= 1'b0;

        wait (s00_axi_rvalid);
        @(posedge s00_axi_aclk);
        s00_axi_rready <= 1'b0;
        rdata <= s00_axi_rdata;

        $display("[%0t] AXI READ : RADDR = 0c%0h,\tRDATA - 0x%0h", $time,
                 s00_axi_araddr, s00_axi_rdata);
    endtask

    initial begin
        s00_axi_aclk = 0;
        s00_axi_aresetn = 0;

        repeat (3) @(posedge s00_axi_aclk);
        s00_axi_aresetn = 1;

        repeat (2) @(posedge s00_axi_aclk);
        axi_write(32'h00, 32'h11111111);
        axi_write(32'h04, 32'h22222222);
        axi_write(32'h08, 32'h33333333);
        axi_write(32'h0c, 32'h44444444);

        repeat (2) @(posedge s00_axi_aclk);
        axi_read(32'h00);
        axi_read(32'h04);
        axi_read(32'h08);
        axi_read(32'h0c);

        repeat (4) @(posedge s00_axi_aclk);
        $finish;
    end


endmodule
