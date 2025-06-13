`include "InstructionMemory.v"
`include "decoder.v"
`include "alu.v"
`include "memory.v"
`include "control.v"
`include "regfile.v"

module cpu(clk, PC);
    input clk;
    output reg [31:0] PC;
    initial PC = 0;

    wire [31:0] Instruction;
    InstructionMemory inst_mem(
        .pc         (PC),
        .instruction(Instruction)
    );

    parameter bitCount = 32;
    wire [6:0]  opcode;
    wire [4:0]  rd, rs1, rs2;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [31:0] imm;
    wire        BR_EQ, BR_NQ, LOAD, STORE;

    decoder u_decoder(
        .Instruction(Instruction),
        .Opcode    (opcode),
        .IMM       (imm),
        .funct7    (funct7),
        .rs2       (rs2),
        .rs1       (rs1),
        .rd        (rd),
        .funct3    (funct3),
        .BR_EQ     (BR_EQ),
        .BR_NQ     (BR_NQ),
        .LOAD      (LOAD),
        .STORE     (STORE)
    );

    wire ALUSrc, BSEL, CISEL, LOGICAL_OA, LogicalOp;
    wire MemRead, MemWrite, RegWrite, Branch, Jump, MemtoReg;

    control u_control(
        .OP         (opcode),
        .funct3     (funct3),
        .funct7     (funct7),
        .BSEL       (BSEL),
        .CISEL      (CISEL),
        .LOGICAL_OA (LOGICAL_OA),
        .ALUSrc     (ALUSrc),
        .MemRead    (MemRead),
        .MemWrite   (MemWrite),
        .RegWrite   (RegWrite),
        .Branch     (Branch),
        .Jump       (Jump),
        .MemtoReg   (MemtoReg),
        .LogicalOp  (LogicalOp)
    );

    wire [31:0] regfile_rs1, regfile_rs2;
    wire [31:0] wb_data;

    regfile u_regfile(
        .clk         (clk),
        .WB          (RegWrite),
        .rs1_address (rs1),
        .rs2_address (rs2),
        .rd_address  (rd),
        .write_data  (wb_data),
        .rs1_data    (regfile_rs1),
        .rs2_data    (regfile_rs2)
    );

    wire [31:0] alu_result;
    wire C, V, N, Z;

    alu u_alu(
        .A        (regfile_rs1),
        .B        (regfile_rs2),
        .imm      (imm),
        .ALUSrc   (ALUSrc),
        .BSEL     (BSEL),
        .CISEL    (CISEL),
        .LOGICAL_OA(LOGICAL_OA),
        .LogicalOp(LogicalOp),
        .Y        (alu_result),
        .C        (C),
        .V        (V),
        .N        (N),
        .Z        (Z)
    );

    reg  [31:0] mem_address, mem_write_data;
    wire [31:0] mem_read_data;

    assign wb_data = MemtoReg ? mem_read_data : alu_result;

    always @(*) begin
        mem_address    = alu_result;
        mem_write_data = regfile_rs2;
    end

    memory inst_memory(
        .address   (mem_address),
        .write_data(mem_write_data),
        .mem_read  (MemRead),
        .mem_write (MemWrite),
        .read_data (mem_read_data)
    );

    always @(posedge clk) begin
        if      (Branch && BR_EQ  &&  Z)  PC <= PC + imm;
        else if (Branch && BR_NQ && ~Z)  PC <= PC + imm;
        else                              PC <= PC + 4;
    end
endmodule
