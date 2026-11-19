`timescale 1ns / 1ps


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

    logic [31:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3;
    logic [31:0] aw_addr, ar_addr;


    // write tr

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
            // if (AWVALID) aw_addr = AWADDR;
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
                AWREADY = 1'b1;
                aw_addr = AWADDR;
                aw_state_next = AW_IDLE;
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
        end
    end

    always_comb begin
        w_state_next = w_state;
        WREADY = 1'b0;

        case (w_state)
            W_IDLE: begin
                if (WVALID & AWVALID & AWREADY) w_state_next = W_READY;
            end
            W_READY: begin
                WREADY = 1'b1;

                case (aw_addr[3:2])
                    2'd0: slv_reg0 = WDATA;
                    2'd1: slv_reg1 = WDATA;
                    2'd2: slv_reg2 = WDATA;
                    2'd3: slv_reg3 = WDATA;
                endcase

                w_state_next = W_IDLE;
            end
            default: begin
                w_state_next = W_IDLE;
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
        BRESP = 2'b0;
        BVALID = 1'b0;

        case (b_state)
            B_IDLE: begin
                if (WVALID & WREADY) b_state_next = B_VALID;
            end
            B_VALID: begin
                BRESP  = 2'b0;
                BVALID = 1'b1;
                if (BREADY) b_state_next = B_IDLE;
            end
            default: begin
                b_state_next = B_IDLE;
            end
        endcase
    end

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
            // if (ARVALID) ar_addr = ARADDR;
        end
    end

    always_comb begin
        ar_state_next = ar_state;
        ARREADY = 1'b0;

        case (ar_state)
            AR_IDLE: begin
                if (ARVALID) ar_state_next = AR_READY;
            end
            AR_READY: begin
                ARREADY = 1'b1;
                ar_addr = ARADDR;
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
        end
    end

    always_comb begin
        r_state_next = r_state;
        RRESP = 2'b0;
        RDATA = 0;
        RVALID = 1'b0;

        case (r_state)
            R_IDLE: begin
                if (ARVALID & ARREADY) r_state_next = R_VALID;
            end
            R_VALID: begin
                RRESP  = 2'b0;
                RVALID = 1'b1;
                
                case (ar_addr[3:2])
                2'd0: RDATA = slv_reg0;
                2'd1: RDATA = slv_reg1;
                2'd2: RDATA = slv_reg2;
                2'd3: RDATA = slv_reg3;
                endcase

                if (RREADY) r_state_next = R_IDLE;
            end
            default: begin
                r_state_next = R_IDLE;
            end
        endcase
    end

endmodule
