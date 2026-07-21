`timescale 1ns / 1ps

module clk_div_2 (
    input  clk,
    input  reset,
    output o_50mhz
);

    reg clk_reg;

    assign o_50mhz = clk_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            clk_reg <= 1'b0;
        end else begin
            clk_reg <= ~clk_reg;
        end
    end

endmodule

module clk_div_4 (
    input  clk,
    input  reset,
    output o_25mhz
);

    reg counter_reg;
    reg clk_reg;

    assign o_25mhz = clk_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 1'b0;
            clk_reg <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == 2 - 1) begin
                counter_reg <= 0;
                clk_reg <= ~clk_reg;
            end
        end
    end

endmodule

module clk_div_6 (
    input  clk,
    input  reset,
    output o_16mhz
);

    reg [1:0] counter_reg;
    reg clk_reg;

    assign o_16mhz = clk_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 2'b0;
            clk_reg <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == 3 - 1) begin
                counter_reg <= 0;
                clk_reg <= ~clk_reg;
            end
        end
    end

endmodule

module clk_div_12 (
    input  clk,
    input  reset,
    output o_8mhz
);

    reg [2:0] counter_reg;
    reg clk_reg;

    assign o_8mhz = clk_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 3'b0;
            clk_reg <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == 6 - 1) begin
                counter_reg <= 0;
                clk_reg <= ~clk_reg;
            end
        end
    end

endmodule

module clk_div_12_2_1 (
    input  clk,
    input  reset,
    output o_8mhz
);

    reg [3:0] counter_reg;
    reg clk_reg;

    assign o_8mhz = clk_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 4'b0;
            clk_reg <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == 4 - 1) begin
                clk_reg <= 1'b1;
            end
            if (counter_reg == 12 - 1) begin
                counter_reg <= 0;
                clk_reg <= 1'b0;
            end
        end
    end

endmodule

module clk_div_12_1_2 (
    input  clk,
    input  reset,
    output o_8mhz
);

    reg [3:0] counter_reg;
    reg clk_reg;

    assign o_8mhz = clk_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 4'b0;
            clk_reg <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == 8 - 1) begin
                clk_reg <= 1'b1;
            end
            if (counter_reg == 12 - 1) begin
                counter_reg <= 0;
                clk_reg <= 1'b0;
            end
        end
    end

endmodule
