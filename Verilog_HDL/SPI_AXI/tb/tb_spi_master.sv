`timescale 1ns / 1ps

module tb_spi_axi_master_slave ();

    parameter integer C_S00_AXI_DATA_WIDTH = 32;
    parameter integer C_S00_AXI_ADDR_WIDTH = 4;

    logic                                  clk;
    logic                                  rstn;

    logic [                           7:0] s_tx_data;
    logic [                           7:0] s_rx_data;
    logic [                           7:0] m_tx_data;
    logic [                           7:0] m_rx_data;

    logic                                  s_busy;
    logic                                  s_done;

    logic                                  sclk;
    logic                                  mosi;
    logic                                  miso;
    logic                                  ss_n;

    // User ports ends
    // Do not modify the ports beyond this line


    // Ports of Axi Slave Bus Interface S00_AXI
    logic                                  s00_axi_aclk;
    logic                                  s00_axi_aresetn;
    logic [    C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr;
    logic [                         2 : 0] s00_axi_awprot;
    logic                                  s00_axi_awvalid;
    logic                                  s00_axi_awready;
    logic [    C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata;
    logic [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb;
    logic                                  s00_axi_wvalid;
    logic                                  s00_axi_wready;
    logic [                         1 : 0] s00_axi_bresp;
    logic                                  s00_axi_bvalid;
    logic                                  s00_axi_bready;
    logic [    C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr;
    logic [                         2 : 0] s00_axi_arprot;
    logic                                  s00_axi_arvalid;
    logic                                  s00_axi_arready;
    logic [    C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata;
    logic [                         1 : 0] s00_axi_rresp;
    logic                                  s00_axi_rvalid;
    logic                                  s00_axi_rready;


    assign s00_axi_aclk  = clk;
    assign s00_axi_aresetn = rstn;

    spi_master_v1_0 dut_axi_master (.*);

    spi_slave dut_s (
        .clk (clk),
        .rstn(rstn),

        // internal signals
        .tx_data(s_tx_data),
        .rx_data(s_rx_data),
        .busy(s_busy),
        .done(s_done),

        // external port
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .ss_n(ss_n)
    );

    task spi_sendData(input logic [31:0] addr, input logic [7:0] m_data,
                      input logic [7:0] s_data);
        @(posedge clk);
        s00_axi_awaddr  = addr;
        s00_axi_awvalid = 1;

        s00_axi_wdata   = m_data;
        s00_axi_wvalid  = 1;
        s00_axi_wstrb   = 4'b1111;

        s00_axi_bready <= 1;

        s_tx_data = s_data;

        @(posedge clk);
        wait (s00_axi_awvalid && s00_axi_wready);
        @(posedge clk);
        s00_axi_awvalid = 0;
        s00_axi_wvalid  = 0;

        wait (s00_axi_bvalid);
        @(posedge clk);
        s00_axi_bready = 0;

        // @(posedge clk);
        // wait(s_done);

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
        // $display("[%t] axi read: addr = %x, data = %x", $time, addr,
        //          s00_axi_rdata);

        @(posedge clk);

    endtask

    always #5 clk = ~clk;
    initial clk = 0;

    localparam SR_ADDR = 32'h00000000;
    localparam TDR_ADDR = 32'h00000004;
    localparam RDR_ADDR = 32'h00000008;
    localparam BRR_ADDR = 32'h0000000C;

    logic [31:0] sr, rdata;

    initial begin
        rstn = 0;
        repeat (3) @(posedge clk);
        rstn = 1;
        repeat (3) @(posedge clk);

        do begin
            axi_readData(SR_ADDR,
                         sr); // sr의 0번째 비트: tx busy를 확인하고 write data
        end while (sr & (1 << 0));

        // clk div 설정
        spi_sendData(BRR_ADDR, 4, 0);

        m_tx_data = 8'haa;
        s_tx_data = 8'h55;
        spi_sendData(TDR_ADDR, 8'haa, 8'h55);

        do begin
            axi_readData(SR_ADDR,
                         sr); // sr의 1번째 비트: rx done flag를 확인하고 read data
        end while (!(sr & (1 << 1)));

        axi_readData(RDR_ADDR, rdata);
        
        if ((m_tx_data == s_rx_data) && (rdata[7:0] == s_tx_data)) begin
            $display(
                "[%t] PASS: master tx %x == slave rx %x, master rx %x == slave tx %x",
                $time, m_tx_data, s_rx_data, rdata[7:0], s_tx_data);
        end else begin
            $display(
                "[%t] FAIL: master tx %x, slave rx %x, master rx %x, slave tx %x",
                $time, m_tx_data, s_rx_data, rdata[7:0], s_tx_data);
        end
        repeat (20) @(posedge clk);
        // end

        $finish;
    end


endmodule

module tb_spi_master_slave ();

    logic       clk;
    logic       rstn;

    logic [7:0] clk_div;
    logic       start;

    logic [7:0] m_tx_data;
    logic [7:0] m_rx_data;
    logic [7:0] s_tx_data;
    logic [7:0] s_rx_data;

    logic       m_busy;
    logic       m_done;
    logic       s_busy;
    logic       s_done;

    logic       sclk;
    logic       mosi;
    logic       miso;
    logic       ss_n;

    spi_master dut_m (
        .clk (clk),
        .rstn(rstn),

        // internal signals
        .clk_div(clk_div),
        .start(start),
        .tx_data(m_tx_data),
        .rx_data(m_rx_data),
        .busy(m_busy),
        .done(m_done),

        // external port
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .ss_n(ss_n)
    );

    spi_slave dut_s (
        .clk (clk),
        .rstn(rstn),

        // internal signals
        .tx_data(s_tx_data),
        .rx_data(s_rx_data),
        .busy(s_busy),
        .done(s_done),

        // external port
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .ss_n(ss_n)
    );

    task spi_sendData(input logic [7:0] m_data, input logic [7:0] s_data);
        @(posedge clk);
        m_tx_data = m_data;
        s_tx_data = s_data;
        start = 1;
        @(posedge clk);
        start = 0;
        wait (s_done);
        @(posedge clk);
    endtask

    always #5 clk = ~clk;
    initial clk = 0;

    initial begin
        rstn = 0;
        repeat (3) @(posedge clk);
        rstn = 1;
        repeat (3) @(posedge clk);

        clk_div = 4;
        @(posedge clk);

        repeat (100) begin
            spi_sendData($urandom, $urandom);
            if ((m_tx_data == s_rx_data) && (m_rx_data == s_tx_data)) begin
                $display(
                    "[%t] PASS: master tx %x == slave rx %x, master rx %x == slave tx %x",
                    $time, m_tx_data, s_rx_data, m_rx_data, s_tx_data);
            end else begin
                $display(
                    "[%t] FAIL: master tx %x, slave rx %x, master rx %x, slave tx %x",
                    $time, m_tx_data, s_rx_data, m_rx_data, s_tx_data);
            end
            repeat (20) @(posedge clk);
        end

        $finish;
    end

endmodule

module tb_spi_master ();

    logic        clk;
    logic        rstn;

    // internal signals
    logic [31:0] clk_div;
    logic        start;
    logic [ 7:0] tx_data;
    logic [ 7:0] rx_data;
    logic        busy;
    logic        done;

    // external port
    logic        sclk;
    logic        w_loop;
    logic        ss_n;

    spi_master dut_m (
        .mosi(w_loop),
        .miso(w_loop),
        .*
    );

    task spi_sendData(input logic [7:0] data);
        @(posedge clk);
        tx_data = data;
        start   = 1;
        @(posedge clk);
        start = 0;
        wait (done);
        @(posedge clk);
    endtask

    always #5 clk = ~clk;
    initial clk = 0;

    initial begin
        rstn = 0;
        repeat (3) @(posedge clk);
        rstn = 1;
        repeat (3) @(posedge clk);

        clk_div = 4;
        @(posedge clk);

        spi_sendData(8'h55);
        repeat (20) @(posedge clk);
        spi_sendData(8'haa);
        repeat (20) @(posedge clk);
        spi_sendData(8'h11);
        repeat (20) @(posedge clk);
        spi_sendData(8'b11001100);
        repeat (20) @(posedge clk);
        spi_sendData(8'b01100110);
        repeat (20) @(posedge clk);

        $finish;
    end

endmodule
