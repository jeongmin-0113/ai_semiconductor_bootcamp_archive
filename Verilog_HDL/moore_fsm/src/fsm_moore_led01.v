`timescale 1ns / 1ps

module fsm_moore_led03 (
    input            clk,
    input            reset,
    input      [2:0] sw,
    output reg [2:0] led
);

    parameter S0 = 3'b111;
    parameter S1 = 3'b001;
    parameter S2 = 3'b010;
    parameter S3 = 3'b011;
    parameter S4 = 3'b100;

    reg [2:0] current_state, next_state;

    // state reg
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            current_state <= S0;
        end else begin
            current_state <= next_state;
        end
    end

    // next state CL
    always @(*) begin
        case (current_state)
            S0: begin
                case (sw)
                    S1: next_state = S1;
                    S4: next_state = S4;
                    default: next_state = current_state;
                endcase
            end
            S1: begin
                if (sw == S2) next_state = S2;
                else next_state = current_state;
            end
            S2: begin
                if (sw == S3) next_state = S3;
                else next_state = current_state;
            end
            S3: begin
                if (sw == S4) next_state = S4;
                else next_state = current_state;
            end
            S4: begin
                case (sw)
                    S1: next_state = S1;
                    S0: next_state = S0;
                    default: next_state = current_state;
                endcase
            end
            default: next_state = current_state;
        endcase
    end

    // output CL
    always @(*) begin
        case (current_state)
            S0: led = 3'b000;
            S1: led = 3'b001;
            S2: led = 3'b010;
            S3: led = 3'b011;
            S4: led = 3'b100;
            default: led = 3'b000;
        endcase
    end

endmodule

module fsm_moore_led03_example (
    input            clk,
    input            reset,
    input      [2:0] sw,
    output reg [2:0] led
);

    parameter S0 = 3'b111;
    parameter S1 = 3'b001;
    parameter S2 = 3'b010;
    parameter S3 = 3'b011;
    parameter S4 = 3'b100;

    reg [2:0] current_state, next_state;

    // state reg
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            current_state <= S0;
        end else begin
            current_state <= next_state;
        end
    end

    // next state CL
    always @(*) begin
        // 초기값 넣어주는 방법으로도 full case 처리 가능함!!
        next_state = current_state;
        case (current_state)
            S0: begin
                case (sw)
                    S1: next_state = S1;
                    S4: next_state = S4;
                endcase
            end
            S1: begin
                if (sw == S2) next_state = S2;
            end
            S2: begin
                if (sw == S3) next_state = S3;
            end
            S3: begin
                if (sw == S4) next_state = S4;
            end
            S4: begin
                case (sw)
                    S1: next_state = S1;
                    S0: next_state = S0;
                endcase
            end
        endcase
    end

    // output CL
    always @(*) begin
        case (current_state)
            S0: led = 3'b000;
            S1: led = 3'b001;
            S2: led = 3'b010;
            S3: led = 3'b011;
            S4: led = 3'b100;
            default: led = 3'b000;
        endcase
    end

endmodule

module fsm_moore_led01 (
    input clk,
    input reset,
    input sw,
    output reg led
);
    parameter S0 = 1'b0;
    parameter S1 = 1'b1;

    // state register
    reg current_state, next_state;

    // state register 
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            current_state <= S0;
        end else begin
            current_state <= next_state;
        end
    end

    // next state combinationial logic
    always @(*) begin
        case (current_state)
            S0: begin
                if (sw) begin
                    next_state = S1;
                end else begin
                    next_state = S0;
                end
            end
            S1: begin
                if (!sw) begin
                    next_state = S0;
                end else begin
                    next_state = S1;
                end
            end
            default: next_state = current_state;
        endcase
    end

    // output combinationial logic
    // assign led = (current_state == S1) ? 1'b1 : 1'b0;
    always @(*) begin
        if (current_state == S0) begin
            led = 1'b0;
        end else begin
            led = 1'b1;
        end
    end
endmodule
