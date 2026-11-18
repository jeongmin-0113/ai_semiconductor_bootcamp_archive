`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/18 14:13:33
// Design Name: 
// Module Name: axi_master
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


module axi_master (
    input ACLK,    // axi에서는 앞에 a 붙암
    input ARESETn, // negative reset

    // internal signal
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,
    input  logic        write,
    input  logic        transfer,
    output logic        ready,

    // aw channel
    output logic [31:0] AWADDR,
    output logic        AWVALID,
    input  logic        AWREADY,

    // w channel
    output logic [31:0] WDATA,
    output logic        WVALID,
    input  logic        WREADY,

    // b channel
    input  logic [1:0] BRESP,
    input  logic       BVALID,
    output logic       BREADY,

    // ar channel
    output logic [31:0] ARADDR,
    output logic        ARVALID,
    input  logic        ARREADY,

    // r channel
    input  logic [31:0] RDATA,
    input  logic        RVALID,
    output logic        RREADY,
    input  logic [ 1:0] RRESP
);
    logic w_ready, read_ready;
    assign ready = w_ready | read_ready;

    // write transaction

    // aw channel
    typedef enum logic {
        AW_IDLE  = 0,
        AW_VALID
    } aw_state_e;

    aw_state_e aw_state, aw_state_next;

    always_ff @(posedge ACLK) begin
        if (!ARESETn) begin
            aw_state <= AW_IDLE;
        end else begin
            aw_state <= aw_state_next;
        end
    end

    always_comb begin
        // init - avoid latch
        aw_state_next = aw_state;
        AWVALID = 1'b0;
        AWADDR = addr;

        case (aw_state)
            AW_IDLE: begin
                if (transfer && write) begin
                    aw_state_next = AW_VALID;
                end
                AWVALID = 1'b0;
            end
            AW_VALID: begin
                if (AWREADY) begin
                    aw_state_next = AW_IDLE;
                end
                AWADDR  = addr;
                AWVALID = 1'b1;
            end
            default: begin
                aw_state_next = AW_IDLE;
                AWVALID = 1'b0;
            end
        endcase
    end

    // w channel
    typedef enum logic {
        W_IDLE  = 0,
        W_VALID
    } w_state_e;

    w_state_e w_state, w_state_next;

    always_ff @(posedge ACLK) begin
        if (!ARESETn) begin
            w_state <= W_IDLE;
        end else begin
            w_state <= w_state_next;
        end
    end

    always_comb begin
        w_state_next = w_state;
        WVALID = 1'b0;
        WDATA = wdata;

        case (w_state)
            W_IDLE: begin
                if (transfer && write) begin
                    w_state_next = W_VALID;
                end
                WVALID = 1'b0;
            end
            W_VALID: begin
                if (WREADY) begin
                    w_state_next = W_IDLE;
                end
                WDATA  = wdata;
                WVALID = 1'b1;
            end
            default: begin
                w_state_next = W_IDLE;
                WVALID = 1'b0;
            end
        endcase
    end

    // b channel
    typedef enum logic {
        B_IDLE  = 0,
        B_READY
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
        BREADY = 1'b0;
        w_ready = 1'b0;

        case (b_state)
            B_IDLE: begin
                if (WVALID) begin
                    b_state_next = B_READY;
                end
                BREADY = 1'b0;
            end
            B_READY: begin
                if (BVALID) begin
                    b_state_next = B_IDLE;
                    w_ready = 1'b1;
                end
                BREADY = 1'b1;
            end
            default: begin
                b_state_next = B_IDLE;
                BREADY = 1'b0;
            end
        endcase
    end

    // read transaction

    // ar channel
    typedef enum logic {
        AR_IDLE  = 0,
        AR_VALID
    } ar_state_e;

    ar_state_e ar_state, ar_state_next;

    always_ff @(posedge ACLK) begin
        if (!ARESETn) begin
            ar_state <= AR_IDLE;
        end else begin
            ar_state <= ar_state_next;
        end
    end

    always_comb begin
        ar_state_next = ar_state;
        ARVALID = 1'b0;
        ARADDR = addr;

        case (ar_state)
            AR_IDLE: begin
                if (transfer && !write) begin
                    ar_state_next = AR_VALID;
                end
                ARVALID = 1'b0;
            end
            AR_VALID: begin
                if (ARREADY) begin
                    ar_state_next = AR_IDLE;
                end
                ARADDR  = addr;
                ARVALID = 1'b1;
            end
            default: begin
                ar_state_next = AR_IDLE;
                ARVALID = 1'b0;
            end
        endcase
    end

    // r channel
    typedef enum logic {
        R_IDLE  = 0,
        R_READY
    } r_state_e;

    r_state_e r_state, r_state_next;

    always_ff @(posedge ACLK) begin
        if (!ARESETn) begin
            r_state <= R_IDLE;
        end else begin
            r_state <= r_state_next;
        end
    end

    always_comb begin
        r_state_next = r_state;
        RREADY = 1'b0;
        rdata = RDATA;
        read_ready = 1'b0;

        case (r_state)
            R_IDLE: begin
                if (ARVALID) begin
                    r_state_next = R_READY;
                end
                RREADY = 1'b0;
            end
            R_READY: begin
                if (RVALID) begin
                    r_state_next = R_IDLE;
                    rdata = RDATA;
                    read_ready = 1'b1;
                end
                RREADY = 1'b1;
            end
            default: begin
                r_state_next = R_IDLE;
                RREADY = 1'b0;
            end
        endcase
    end

endmodule
