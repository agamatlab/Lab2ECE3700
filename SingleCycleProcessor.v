`timescale 1ns / 1ps

`include "alu.v"
`include "InstructionMemory.v"
`include "decoder.v"
`include "ImmediateGenerator.v"
`include "control.v"
`include "regfile.v"
`include "memory.v"
`include "mux2to1.v"

module SingleCycleProcessor(
    input clk
);

    // PC register
    reg  [31:0] PC_cs;
    wire [31:0] pc     = PC_cs;
    initial     PC_cs  = 0;
    always @(posedge clk)
        PC_cs <= next_pc;

    // Instruction fetch
    wire [31:0] Inst;
    InstructionMemory InstMem1(
        .address    (pc),
        .instruction(Inst)
    );

    // Decode
    wire [6:0]  OP, funct7;
    wire [2:0]  funct3;
    wire [4:0]  rs1, rs2, rd;
    wire        BR_EQ, BR_NQ, LOAD, STORE;

    decoder dec(
        .Instruction(Inst),
        .Opcode     (OP),
        .funct7     (funct7),
        .funct3     (funct3),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .BR_EQ      (BR_EQ),
        .BR_NQ      (BR_NQ),
        .LOAD       (LOAD),
        .STORE      (STORE)
    );

    // Immediate generation
    wire [31:0] IMM;
    ImmediateGenerator immgen(
        .Instruction(Inst),
        .Opcode     (OP),
        .IMM        (IMM)
    );

    // Control signals
    wire ALUSrc, BSEL, CISEL, LOGICAL_OA, LogicalOp;
    wire MemRead, MemWrite, RegWrite, Branch, Jump, MemtoReg;
    wire BType = BR_EQ || BR_NQ;

    control cu(
         .OP         (OP),
         .funct7     (funct7),
         .funct3     (funct3),
         .LOAD       (LOAD),
         .STORE      (STORE),
         .BType      (BType),
         .ALUSrc     (ALUSrc),
         .BSEL       (BSEL),
         .CISEL      (CISEL),
         .LOGICAL_OA (LOGICAL_OA),
         .LogicalOp  (LogicalOp),
         .MemRead    (MemRead),
         .MemWrite   (MemWrite),
         .RegWrite   (RegWrite),
         .Branch     (Branch),
         .Jump       (Jump),
         .MemtoReg   (MemtoReg)
    );

    // Register file
    wire [31:0] rd1, rd2;
    wire [31:0] wb_data;
    regfile RF1(
        .clk         (clk),
        .WB          (RegWrite),
        .rs1_address (rs1),
        .rs2_address (rs2),
        .rd_address  (rd),
        .write_data  (wb_data),
        .rs1_data    (rd1),
        .rs2_data    (rd2)
    );

    // ALU
    wire [31:0] alu_out;
    wire        C, V, N, Z;
    alu u_alu(
        .A          (rd1),
        .B          (rd2),
        .imm        (IMM),
        .ALUSrc     (ALUSrc),
        .BSEL       (BSEL),
        .CISEL      (CISEL),
        .LOGICAL_OA (LOGICAL_OA),
        .LogicalOp  (LogicalOp),
        .Y          (alu_out),
        .C          (C),
        .V          (V),
        .N          (N),
        .Z          (Z)
    );

    // Data memory
    wire [31:0] mem_rd;
    memory DataMem1(
        .clk        (clk),
        .address    (alu_out),
        .write_data (rd2),
        .mem_read   (MemRead),
        .mem_write  (MemWrite),
        .read_data  (mem_rd)
    );

    // write-back MUX instead of assign with ternary
    mux2to1 wb_mux (
        .in0 (alu_out),
        .in1 (mem_rd),
        .sel (MemtoReg),
        .out (wb_data)
    );

    // Next-PC calculation
    wire [31:0] pc_plus4       = pc + 4;
    wire        take_branch    = (BR_EQ  && Z) || (BR_NQ && !Z);
    wire [31:0] branch_target  = pc + IMM;
    wire        branch_sel     = Branch && take_branch;
    wire [31:0] next_pc;

    // PC MUX instead of ternary
    mux2to1 pc_mux (
        .in0 (pc_plus4),
        .in1 (branch_target),
        .sel (branch_sel),
        .out (next_pc)
    );

endmodule
