`timescale 1ns / 1ps

module tb_axi_uart ();

    parameter integer C_S00_AXI_DATA_WIDTH = 32;
    parameter integer C_S00_AXI_ADDR_WIDTH = 4;

    logic clk, rstn;
    logic loop;

    logic intr;  // interrupt (rx done)

    // Ports of Axi Slave Bus Interface S00_AXI
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

    assign s00_axi_aclk = clk;
    assign s00_axi_aresetn = rstn;

    uart_v1_0 dut (
        .tx(loop),
        .rx(loop),
        .*
    );

    task axi_writeData(logic [31:0] addr, logic [31:0] data);
        @(posedge clk);
        s00_axi_awaddr  <= addr;
        s00_axi_awvalid <= 1;

        s00_axi_wdata   <= data;
        s00_axi_wvalid  <= 1;
        s00_axi_wstrb   <= 4'b1111;

        s00_axi_bready  <= 1;

        @(posedge clk);
        wait (s00_axi_awready && s00_axi_wready);
        @(posedge clk);
        // w & aw handshake 끝 -> valid 0
        s00_axi_awvalid <= 0;
        s00_axi_wvalid  <= 0;

        @(posedge clk);
        wait (s00_axi_bvalid);
        @(posedge clk);
        // b handshake 끝 -> valid 0
        s00_axi_bready <= 0;
        $display("[%t] axi write: addr = %x, data = %x", $time, addr, data);

        @(posedge clk);
    endtask

    task axi_readData(input logic [31:0] addr, output logic [31:0] data);
        @(posedge clk);
        s00_axi_araddr  <= addr;
        s00_axi_arvalid <= 1;

        s00_axi_rready  <= 1;

        @(posedge clk);
        wait (s00_axi_arready);
        @(posedge clk);
        s00_axi_arvalid <= 0;

        @(posedge clk);
        wait (s00_axi_rvalid);
        @(posedge clk);
        s00_axi_rready <= 0;
        data <= s00_axi_rdata;
        $display("[%t] axi read: addr = %x, data = %x", $time, addr,
                 s00_axi_rdata);

        @(posedge clk);

    endtask

    always #5 clk = ~clk;

    localparam SR_ADDR = 32'h00000000;
    localparam TDR_ADDR = 32'h00000004;
    localparam RDR_ADDR = 32'h00000008;
    localparam CR_ADDR = 32'h0000000C;

    logic [31:0] rdata, sr, tx_data;

    initial begin
        clk  = 0;
        rstn = 0;
        repeat (3) @(posedge clk);
        rstn = 1;
        repeat (3) @(posedge clk);

        do begin
            axi_readData(SR_ADDR,
                         sr); // sr의 0번째 비트: tx busy를 확인하고 write data
        end while (sr & (1 << 0));

        // 인터럽트 들어오는지 확인
        axi_writeData(CR_ADDR, 8'h01);

        tx_data = 8'haa;
        axi_writeData(TDR_ADDR, tx_data);  // 10101010

        do begin
            axi_readData(SR_ADDR,
                         sr); // sr의 1번째 비트: rx done flag를 확인하고 read data
        end while (!(sr & (1 << 1)));

        axi_readData(RDR_ADDR, rdata);

        if (tx_data == rdata) begin
            $display("[%t] PASS: tx data = %x, rx data = %x", $time, tx_data, rdata);
        end else begin
            $display("[%t] FAIL: tx data = %x, rx data = %x", $time, tx_data, rdata);
        end

        repeat (3) @(posedge clk);

                do begin
            axi_readData(SR_ADDR,
                         sr); // sr의 0번째 비트: tx busy를 확인하고 write data
        end while (sr & (1 << 0));

        // 인터럽트 안들어와야함
        axi_writeData(CR_ADDR, 8'h00);

        tx_data = 8'h44;
        axi_writeData(TDR_ADDR, tx_data);  // 10101010

        do begin
            axi_readData(SR_ADDR,
                         sr); // sr의 1번째 비트: rx done flag를 확인하고 read data
        end while (!(sr & (1 << 1)));

        axi_readData(RDR_ADDR, rdata);

        if (tx_data == rdata) begin
            $display("[%t] PASS: tx data = %x, rx data = %x", $time, tx_data, rdata);
        end else begin
            $display("[%t] FAIL: tx data = %x, rx data = %x", $time, tx_data, rdata);
        end

        repeat (3) @(posedge clk);
        $finish;
    end
endmodule
