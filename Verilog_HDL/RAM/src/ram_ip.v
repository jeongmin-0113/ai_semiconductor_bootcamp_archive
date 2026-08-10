`timescale 1ns / 1ps

module ram_id (
    input        clk,
    input  [9:0] addr,
    input  [7:0] wdata,
    input        wr,
    output reg [7:0] rdata
);

    reg [7:0] ram[0:1023];

    always @(posedge clk) begin
        if (wr) begin
            // wr == 1: write 모드
            ram[addr] <= wdata;
        end
        else begin
            // wr == 0: read 모드
            // CL 출력보다 1clk 지연됨
            rdata <= ram[addr];
        end
    end

    // CL output (read)
    // wr == 0: read 모드일때만 rdata 내보냄
    //assign rdata = (!wr) ? ram[addr] : 8'hz;
    
    // wr 상관 없이 그냥 내보낼 때는 이렇게
    //assign rdata = ram[addr];

endmodule