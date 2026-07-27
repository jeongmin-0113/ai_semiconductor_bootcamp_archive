`timescale 1ns / 1ps

module pattern_detection_mealy (
    input  clk,
    input  reset,
    input  i_pattern,
    output o_detect
);

    // state
    parameter START = 2'b00;
    parameter S_0 = 2'b01;
    parameter S_01 = 2'b10;
    parameter S_010 = 2'b11;

    reg [1:0] c_state, n_state;

    // output CL
    assign o_detect = ((c_state == S_010) && (i_pattern == 1)) ? 1 : 0;

    // state register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state <= START;
        end else begin
            c_state <= n_state;
        end
    end

    // next state CL
    always @(*) begin
        n_state = START;
        case (c_state)
            START:
            if (i_pattern == 0) n_state = S_0;
            else n_state = START;
            S_0:
            if (i_pattern == 0) n_state = S_0;
            else n_state = S_01;
            S_01:
            if (i_pattern == 0) n_state = S_010;
            else n_state = START;
            S_010:
            if (i_pattern == 0) n_state = S_0;
            else n_state = START;
            default: n_state = START;
        endcase
    end
endmodule

module pattern_detection_moore (
    input  clk,
    input  reset,
    input  i_pattern,
    output o_detect
);

    // state
    parameter START = 3'b000;
    parameter S_0 = 3'b001;
    parameter S_01 = 3'b010;
    parameter S_010 = 3'b011;
    parameter S_0101 = 3'b100;

    reg [2:0] c_state, n_state;

    // output CL
    assign o_detect = (c_state == S_0101) ? 1 : 0;

    // state register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state <= START;
        end else begin
            c_state <= n_state;
        end
    end

    // next state CL
    always @(*) begin
        n_state = START;
        case (c_state)
            START:
            if (i_pattern == 0) n_state = S_0;
            else n_state = START;
            S_0:
            if (i_pattern == 0) n_state = S_0;
            else n_state = S_01;
            S_01:
            if (i_pattern == 0) n_state = S_010;
            else n_state = START;
            S_010:
            if (i_pattern == 0) n_state = S_0;
            else n_state = S_0101;
            S_0101:
            if (i_pattern == 0) n_state = S_0;
            else n_state = START;
            default: n_state = START;
        endcase
    end
endmodule
