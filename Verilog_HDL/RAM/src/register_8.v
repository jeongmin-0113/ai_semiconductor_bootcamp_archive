`timescale 1ns / 1ps

module register_8 (
    input clk,
    input reset,
    input [7:0] d,
    output [7:0] q
);

    reg [7:0] q_reg;
    assign q = q_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            q_reg <= 0;
        end else begin
            q_reg <= d;
            //q <= q_reg;
        end
    end
endmodule

module register_8_we (
    input clk,
    input reset,
    input we,
    input [7:0] d,
    output [7:0] q
);

    reg [7:0] q_reg;
    assign q = q_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            q_reg <= 0;
        end else begin
            if (we) begin
                q_reg <= d;
            end
        end
    end
endmodule
