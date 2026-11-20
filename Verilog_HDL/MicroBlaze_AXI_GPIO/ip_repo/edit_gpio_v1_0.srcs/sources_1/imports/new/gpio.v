`timescale 1ns / 1ps

module gpio (
    // internal port
    input wire [3:0] cr,  // control register
    input wire [3:0] odr,  // output data register (from cpu)
    output wire [3:0] idr,  // input data register (to cpu)
    // external port
    inout wire [3:0] io_port
);

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin
            assign io_port[i] = (cr[i]) ? odr[i] : 1'bz;
            assign idr[i] = (cr[i]) ? 1'bz : io_port[i];
        end
    endgenerate

    // // cr == 1 -> gpo mode
    // assign io_port[1] = (cr[1]) ? odr[0] : 1'bz;
    // assign io_port[2] = (cr[2]) ? odr[0] : 1'bz;
    // assign io_port[3] = (cr[3]) ? odr[0] : 1'bz;

    // // cr == 0 -> gpi mode
    // assign idr[1] = (cr[1]) ? 1'bz : io_port[1];
    // assign idr[2] = (cr[2]) ? 1'bz : io_port[2];
    // assign idr[3] = (cr[3]) ? 1'bz : io_port[3];
endmodule
