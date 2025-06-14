`timescale 1ns / 1ps

`include "alu.v"
`include "InstructionMemory.v"
`include "decoder.v"
`include "control.v"
`include "regfile.v"
`include "memory.v"


module SingleCycleProcessor(
    input clk
);

    // PC register exposed as PC_cs for sim.v
    reg [31:0] PC_cs;
    wire [31:0] pc;
    assign pc = PC_cs;

    initial PC_cs = 0;
    always @(posedge clk) begin
        PC_cs <= next_pc;
    end

    // Instruction fetch
    wire [31:0] Inst;
    InstructionMemory InstMem1(
        .address(pc),
        .instruction(Inst)
    );

    // Decode stage
    wire [6:0]  OP, funct7;
    wire [2:0]  funct3;
    wire [4:0]  rs1, rs2, rd;
    wire [31:0] IMM;
    wire        BR_EQ, BR_NQ, LOAD, STORE;

    decoder dec(
        .Instruction(Inst),
        .Opcode(OP),
        .IMM(IMM),
        .funct7(funct7),
        .rs2(rs2),
        .rs1(rs1),
        .rd(rd),
        .funct3(funct3),
        .BR_EQ(BR_EQ),
        .BR_NQ(BR_NQ),
        .LOAD(LOAD),
        .STORE(STORE)
    );

    // Control signals
    wire ALUSrc, BSEL, CISEL, LOGICAL_OA, LogicalOp;
    wire MemRead, MemWrite, RegWrite, Branch, Jump, MemtoReg;

    wire BType = BR_EQ || BR_NQ;
    control cu(
         .OP(OP),
         .funct7(funct7),
         .funct3(funct3),
         .LOAD(LOAD),
         .STORE(STORE),
         .BType(BType),
         .ALUSrc(ALUSrc),
         .BSEL(BSEL),
         .CISEL(CISEL),
         .LOGICAL_OA(LOGICAL_OA),
         .LogicalOp(LogicalOp),
         .MemRead(MemRead),
         .MemWrite(MemWrite),
         .RegWrite(RegWrite),
         .Branch(Branch),
         .Jump(Jump),
         .MemtoReg(MemtoReg)
    );

    // Register File: instance named RF1 with internal regs array
    wire [31:0] rd1, rd2;
    regfile RF1(
        .clk(clk),
        .WB(RegWrite),
        .rs1_address(rs1),
        .rs2_address(rs2),
        .rd_address(rd),
        .write_data(wb_data),
        .rs1_data(rd1),
        .rs2_data(rd2)
    );

    // ALU
    wire [31:0] alu_out;
    wire C, V, N, Z;
    alu u_alu(
        .A(rd1),
        .B(rd2),
        .imm(IMM),
        .ALUSrc(ALUSrc),
        .BSEL(BSEL),
        .CISEL(CISEL),
        .LOGICAL_OA(LOGICAL_OA),
        .LogicalOp(LogicalOp),
        .Y(alu_out),
        .C(C),
        .V(V),
        .N(N),
        .Z(Z)
    );

    // Data memory: instance named DataMem1 with internal regs array
    wire [31:0] mem_rd;
    memory DataMem1(
        .clk(clk),
        .address(alu_out),
        .write_data(rd2),
        .mem_read(MemRead),
        .mem_write(MemWrite),
        .read_data(mem_rd)
    );

    // Write-back MUX
    wire [31:0] wb_data = MemtoReg ? mem_rd : alu_out;

    // Next PC logic
    wire [31:0] pc_plus4 = pc + 4;
    wire take_branch = (BR_EQ  && Z) || (BR_NQ && !Z);
    wire [31:0] branch_target = pc + (IMM);
    wire [31:0] next_pc =
        (Branch && take_branch) ? branch_target : pc_plus4;

endmodule
