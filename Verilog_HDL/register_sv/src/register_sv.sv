`timescale 1ns / 1ps

module register_sv (
    input  logic        clk,
    input  logic        reset,
    input  logic        enable,
    input  logic [31:0] d,
    output logic [31:0] q
);
    // always_ff (얘는 always랑 차이가 없음) / always_comb (조합)
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            q <= 0;
        end else begin
            if (enable) q <= d;
        end
    end

endmodule
