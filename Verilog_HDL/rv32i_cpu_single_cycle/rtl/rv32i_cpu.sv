// cpu + rom
module rv32i_top (
    input  logic clk,
    input  logic rst_n
);

    logic [31:0] instr_code, instr_addr;
    logic [31:0] d_addr, d_wdata, d_rdata;
    logic [2:0] d_inst_type;
    logic d_we;

    instruction_rom U_ROM (
        .*
    );
    
    rv32i_cpu U_CPU (
        .* 
    );
    
    data_memory U_RAM (
       .* 
    );

endmodule

// cpu
module rv32i_cpu (
    input  logic clk,
    input  logic rst_n,
    input  logic [31:0] instr_code,
    input  logic [31:0] d_rdata,
    output logic [31:0] instr_addr,
    output logic [31:0] d_addr,
    output logic [31:0] d_wdata,
    output logic d_we,
    output logic [2:0] d_inst_type
);
    logic [3:0] alu_control;
    logic rf_we, alu_src_sel;
    logic [2:0] rf_src_sel;
    logic [1:0] jump;

    control_unit U_CNTL_UNIT (
        .*
    );
    
    datapath U_DATAPATH (
        .*
    ); 

endmodule
