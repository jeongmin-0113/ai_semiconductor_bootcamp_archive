`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/18 15:45:36
// Design Name: 
// Module Name: axi_slave
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module axi_slave (
    input ACLK,    // axi에서는 앞에 a 붙암
    input ARESETn, // negative reset

    // aw channel
    input  logic [31:0] AWADDR,
    input  logic        AWVALID,
    output logic        AWREADY,

    // w channel
    input  logic [31:0] WDATA,
    input  logic        WVALID,
    output logic        WREADY,

    // b channel
    output logic [1:0] BRESP,
    output logic       BVALID,
    input  logic       BREADY,

    // ar channel
    input  logic [31:0] ARADDR,
    input  logic        ARVALID,
    output logic        ARREADY,

    // r channel
    output logic [31:0] RDATA,
    output logic        RVALID,
    input  logic        RREADY,
    output logic [ 1:0] RRESP
);
    logic [31:0] w_addr_reg, r_addr_reg;
    logic [31:0] slv_reg[0:3];

    // write transaction

    // aw channel
    typedef enum logic {
        AW_IDLE  = 0,
        AW_READY
    } aw_state_e;

    aw_state_e aw_state, aw_state_next;

    always_ff @(posedge ACLK) begin
        if (!ARESETn) begin
            aw_state <= AW_IDLE;
        end else begin
            aw_state <= aw_state_next;
            if (aw_state == AW_READY) w_addr_reg <= AWADDR;
        end
    end

    always_comb begin
        aw_state_next = aw_state;
        AWREADY = 1'b0;
        case (aw_state)
            AW_IDLE: begin
                if (AWVALID) aw_state_next = AW_READY;
            end
            AW_READY: begin
                aw_state_next = AW_IDLE;
                AWREADY = 1'b1;
            end
            default: begin
                aw_state_next = AW_IDLE;
            end
        endcase
    end

    // w channel
    typedef enum logic {
        W_IDLE  = 0,
        W_READY
    } w_state_e;

    w_state_e w_state, w_state_next;

    always_ff @(posedge ACLK) begin
        if (!ARESETn) begin
            w_state <= W_IDLE;
        end else begin
            w_state <= w_state_next;
            if (WVALID && WREADY) begin
                slv_reg[w_addr_reg[3:2]] <= WDATA;
            end
        end
    end

    always_comb begin
        w_state_next = w_state;
        WREADY = 1'b0;
        case (w_state)
            W_IDLE: begin
                if (AWREADY) begin
                    w_state_next = W_READY;
                end
            end
            W_READY: begin
                WREADY = 1'b1;
                if (WVALID) begin
                    w_state_next = W_IDLE;
                end
            end
            default: begin
                w_state_next = W_READY;
            end
        endcase
    end

    // b channel
    typedef enum logic {
        B_IDLE  = 0,
        B_VALID
    } b_state_e;

    b_state_e b_state, b_state_next;

    always_ff @(posedge ACLK) begin
        if (!ARESETn) begin
            b_state <= B_IDLE;
        end else begin
            b_state <= b_state_next;
        end
    end

    always_comb begin
        b_state_next = b_state;
        BVALID = 1'b0;
        BRESP = 0;

        case (b_state)
            B_IDLE: begin
                if (WVALID && WREADY) begin // wlast나 다 받았을 때 flag 있으면 좋을 것 같긴 함 지금은 데이터 1개 + 1 clock만에 데이터 처리 다 끝나는걸 상정한 로직
                    b_state_next = B_VALID;
                end
            end
            B_VALID: begin
                BRESP  = 0;
                BVALID = 1'b1;
                if (BREADY) b_state_next = B_IDLE;
            end
            default: begin
                b_state_next = B_IDLE;
            end
        endcase
    end

    // read transaction

    // ar channel
    typedef enum logic {
        AR_IDLE  = 0,
        AR_READY
    } ar_state_e;

    ar_state_e ar_state, ar_state_next;

    always_ff @(posedge ACLK) begin
        if (!ARESETn) begin
            ar_state <= AR_IDLE;
        end else begin
            ar_state <= ar_state_next;
            if (ar_state == AR_READY) r_addr_reg <= ARADDR;
        end
    end

    always_comb begin
        ar_state_next = ar_state;
        ARREADY = 1'b0;

        case (ar_state)
            AR_IDLE: begin
                if (ARVALID) begin
                    ar_state_next = AR_READY;
                end
            end
            AR_READY: begin
                ARREADY = 1'b1;
                ar_state_next = AR_IDLE;
            end
            default: begin
                ar_state_next = AR_IDLE;
            end
        endcase
    end

    // r channel
    typedef enum logic {
        R_IDLE  = 0,
        R_VALID
    } r_state_e;

    r_state_e r_state, r_state_next;

    always_ff @(posedge ACLK) begin
        if (!ARESETn) begin
            r_state <= R_IDLE;
        end else begin
            r_state <= r_state_next;
            if (ARVALID && ARREADY) begin
                RDATA <= slv_reg[r_addr_reg[3:2]];
            end
        end
    end

    always_comb begin
        r_state_next = r_state;
        RVALID = 1'b0;
        RRESP = 0;

        case (r_state)
            R_IDLE: begin
                if (ARVALID && ARREADY) begin
                    r_state_next = R_VALID;
                end
            end
            R_VALID: begin
                RRESP  = 0;
                RVALID = 1'b1;
                if (RREADY) r_state_next = R_IDLE;
            end
            default: begin
                r_state_next = R_IDLE;
            end
        endcase
    end

endmodule
