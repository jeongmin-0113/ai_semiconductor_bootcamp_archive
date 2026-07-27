`timescale 1ns / 1ps

module if_if(
    input selA,
    input selB,
    input selC,
    input selD,
    input [3:0] dinA,
    input [3:0] dinB,
    input [3:0] dinC,
    input [3:0] dinD,
    input [3:0] dinE,
    output reg [3:0] dout
    );

    always @(*) begin
        dout = dinE;
        if (selA) dout = dinA;
        if (selB) dout = dinB;
        if (selC) dout = dinC;
        if (selD) dout = dinD;
    end
endmodule

module if_else(
    input selA,
    input selB,
    input selC,
    input selD,
    input [3:0] dinA,
    input [3:0] dinB,
    input [3:0] dinC,
    input [3:0] dinD,
    input [3:0] dinE,
    output reg [3:0] dout
    );

    always @(*) begin
        dout = dinE;
        if (selA) dout = dinA;
        else if (selB) dout = dinB;
        else if (selC) dout = dinC;
        else if (selD) dout = dinD;
    end
endmodule

