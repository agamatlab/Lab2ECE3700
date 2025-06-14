
module ImmediateGenerator(
    input  [31:0] Instruction,
    input  [6:0]  Opcode,
    output reg [31:0] IMM
);
    wire [6:0] IType = 7'b0010011;
    wire [6:0] LType = 7'b0000011;
    wire [6:0] SType = 7'b0100011;
    wire [6:0] BType = 7'b1100011;

    always @(*) begin
        case (Opcode)
            IType, LType: IMM = {{20{Instruction[31]}}, Instruction[31:20]};
            SType:       IMM = {{20{Instruction[31]}}, Instruction[31:25], Instruction[11:7]};
            BType:       IMM = {{19{Instruction[31]}}, Instruction[31], Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0};
            default:     IMM = 32'b0;
        endcase
    end
endmodule
